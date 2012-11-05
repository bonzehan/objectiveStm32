/*
 * main.cpp
 *
 *  Created on: Jan 21, 2012
 *      Author: artur
 */
#include <boardDefs.hpp>

#include <CGpioManager.hpp>
#include <CRccManager.hpp>
#include <CGpio.hpp>

#include <CPeriphalManager.hpp>
#include <Peripherals/PeripheralTypes.hpp>
#include <IPeripheral.hpp>
#include <Peripherals/CLed.hpp>

#include "Peripherals/IPeripheral.hpp"

#include "ExternalModules/KamodRGB.hpp"



int main()
{

    SystemInit();
    
    /*PERIPHERAL MANAGER TEST*/
    CGpioManager GM;    
    CPeriphalManager PM(&GM);
   
    TPeripheralConfigLed ledConfig;
    ledConfig.apb2 = RCC_APB2Periph_GPIOC;
    ledConfig.gpioPin = GPIO_Pin_6;
    ledConfig.gpioPort = GPIOC;
    
    CLed* led = PM.getPeripheral<CLed>(ledConfig);
    
    TPeripheralConfigI2C i2cConfig;
    
    i2cConfig.i2c        = I2C1;
    i2cConfig.gpioPort   = GPIOB;
    i2cConfig.gpioPinScl = GPIO_Pin_8;
    i2cConfig.gpioPinSda = GPIO_Pin_9;
    i2cConfig.apb1       = RCC_APB1Periph_I2C1;
    i2cConfig.apb2       = RCC_APB2Periph_GPIOB | RCC_APB2Periph_AFIO ;
    i2cConfig.remap      = GPIO_Remap_I2C1;

    
    
    CI2C* i2c = PM.getPeripheral<CI2C>(i2cConfig);
    
    i2c->init();
    
    KamodRGB leds(0,i2c);
    
    leds.light(KRed,255);
    
    led->init();
    
    led->on();
    
    int i=0;
    while(1)
    {
        if(i>900000)
        {
            i=0;
            led->toogle();
        }
        i++;
    }   
}


