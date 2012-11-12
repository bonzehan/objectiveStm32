/* 
 * File:   CPeriphalManager.hpp
 * Author: reymondo
 *
 * Created on 12 czerwiec 2012, 18:51
 */

#ifndef CPERIPHALMANAGER_HPP
#define	CPERIPHALMANAGER_HPP

#include <IPeripheral.hpp>
#include <CLed.hpp>
#include <CI2C.hpp>
#include <CUsart.hpp>
#include <CButton.hpp>
#include <PeripheralTypes.hpp>
#include <PeripheralMapsStorage.hpp>
#include <CGpioManager.hpp>
#include <map>
#include <typeinfo>



class CPeriphalManager 
{

    
  public:
    CPeriphalManager(CGpioManager * GM);
    CPeriphalManager(const CPeriphalManager& orig);
    virtual ~CPeriphalManager();
    
    template<typename TPeripheral>
    TPeripheral* getPeripheral(SPeripheralConfig& config);
    
    template<typename TPeripheral>
    void delPeripheral(TPeripheral* periph);
    
  private:
    void enableAPB1(uint32_t  apb1);
    void enableAPB2(uint32_t  apb2);
    void disableAPB1(uint32_t apb1);
    void disableAPB2(uint32_t apb1);
           
    CGpioManager * GM;
    
    PeripheralMapsStorage PeriphMap;
  
};

template<typename TPeripheral>
TPeripheral* CPeriphalManager::getPeripheral(SPeripheralConfig& conf)
{
    typedef typename TPeripheral::TPeripheralConfig TPeripheralConfig;
    typedef typename PeripheralMapTypes<TPeripheral>::TPeriphMap TPeriphMap;
    
    TPeriphMap map = (TPeriphMap&)PeriphMap;
    
    TPeripheralConfig& config = static_cast<TPeripheralConfig&>(conf);
    typename TPeriphMap::iterator iter = map.find(config);
    
    if (iter != map.end())
    {
        iter->second->referenceCounter++;
        return static_cast<TPeripheral*>(iter->second);
    }
   
    enableAPB1(config.apb1);
    enableAPB2(config.apb2);
    GPIO_PinRemapConfig(config.remap, ENABLE);

    TPeripheral* periph = new TPeripheral(GM,config);
    
    map[config] = periph;
    
    return periph;
}

template<typename TPeripheral>
void CPeriphalManager::delPeripheral(TPeripheral* periph)
{
    typedef typename TPeripheral::TPeripheralConfig TPeripheralConfig;
    typedef typename PeripheralMapTypes<TPeripheral>::TPeriphMap TPeriphMap;
    
    TPeriphMap& map = (TPeriphMap&)PeriphMap;
    TPeripheralConfig config;

    typename TPeriphMap::iterator iter;

    for(iter = map.begin();iter!=map.end();iter++)
    {
        if(iter->second == periph)
        {
            config = iter->first;
            iter->second->referenceCounter--;
            if(0 == iter->second->referenceCounter)
            {
                delete periph;
                map.erase(iter);
                GPIO_PinRemapConfig(config.remap, DISABLE);
                
            }            
            break;
        }
    }

    // Check if RCC's are used by other devices and disable these if not
    bool testApb = false;
    for(iter=map.begin();iter!=map.end();iter++)
    {
        if(iter->first.apb1 && config.apb1)
        {
            testApb = true;
            break;
        }
    }
    if(!testApb)
    {
        disableAPB1(config.apb1);
    }
    
    testApb = false;
    for(iter=map.begin();iter!=map.end();iter++)
    {
        if(iter->first.apb2 && config.apb2)
        {
            testApb = true;
            break;
        }
    }
    if(!testApb)
    {
        disableAPB2(config.apb2);
    }
    
}

#endif	/* CPERIPHALMANAGER_HPP */
