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
#include <PeripheralTypes.hpp>
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
      
    template<typename TPeripheral, typename TPeriphMap>
    TPeripheral* getPeripheralImpl(SPeripheralConfig& conf, TPeriphMap& map);
    
    template<typename TPeripheral, typename TPeriphMap>
    void delPeripheralImpl(TPeripheral* periph, TPeriphMap& map);
      
    void enableAPB1(uint32_t apb1);
    void enableAPB2(uint32_t apb2);
    void disableAPB1(uint32_t apb1);
    void disableAPB2(uint32_t apb1);
           
    CGpioManager * GM;
    
    PeripheralTypes<CLed>::TPeriphMap LedPeriphMap;
    PeripheralTypes<CI2C>::TPeriphMap I2CPeriphMap;
  
    //TODO remove referenceCounter ?
    std::map<IPeripheral*,int> referenceCounter;
};

template<typename TPeripheral, typename TPeriphMap>
TPeripheral* CPeriphalManager::getPeripheralImpl(SPeripheralConfig& conf, TPeriphMap& map)
{
    typedef typename TPeripheral::TPeripheralConfig TPeripheralConfig;
    TPeripheralConfig& config = static_cast<TPeripheralConfig&>(conf);
    typename TPeriphMap::iterator iter = map.find(config);
    
    if (iter != map.end())
    {
        //TODO remove referenceCounter ?
        referenceCounter[iter->second]++; 
        return static_cast<TPeripheral*>(iter->second);
    }
   
    enableAPB1(config.apb1);
    enableAPB2(config.apb2);

    TPeripheral* periph = new TPeripheral(GM,config);
    
    //TODO remove referenceCounter ?
    referenceCounter[periph] = 1;
    map[config] = periph;
    
    return periph;
}

template<typename TPeripheral, typename TPeriphMap>
void CPeriphalManager::delPeripheralImpl(TPeripheral* periph, TPeriphMap& map)
{
    typedef typename TPeripheral::TPeripheralConfig TPeripheralConfig;
    TPeripheralConfig config;
    typename TPeriphMap::iterator iter;
    for(iter = map.begin();iter!=map.end();iter++)
    {
        if(iter->second == periph)
        {
            config = iter->first;
            referenceCounter[periph]--;
            if(0 == referenceCounter[periph])
            {
                delete periph;
                map.erase(iter);
                referenceCounter.erase(periph);
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

