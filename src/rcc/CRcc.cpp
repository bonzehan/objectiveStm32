/*
 * CRcc.cpp
 *
 *  Created on: Mar 3, 2012
 *      Author: artur
 */
#include <boardDefs.hpp>
#include "../../inc/rcc/CRcc.hpp"

CRcc::CRcc()
{
}

void CRcc::apb1Enable( uint32_t apb1Value )
{
	increaseUseCount( m_apb1UseCounter, apb1Value );
	RCC_APB1PeriphClockCmd( apb1Value, ENABLE );
}

void CRcc::apb1Disable( uint32_t apb1Value )
{
	uint32_t value = apb1Value;
	uint32_t bitNumber = 0;
	while( value != 0 )
	{
		bitNumber = __builtin_clz( value );
		if ( m_apb1UseCounter[ bitNumber ] != 0 )
		{
			m_apb1UseCounter[ bitNumber ]--;
		}
		if ( m_apb1UseCounter[ bitNumber ] == 0 )
		{
			RCC_APB1PeriphClockCmd( 1<<bitNumber, DISABLE );
		}
		value -= 1<<bitNumber;
	}
}

void CRcc::apb2Enable( uint32_t apb2Value )
{
	increaseUseCount( m_apb2UseCounter, apb2Value );
	RCC_APB1PeriphClockCmd( apb2Value, ENABLE );
}

void CRcc::apb2Disable( uint32_t apb1Value )
{
	uint32_t value = apb1Value;
	uint32_t bitNumber = 0;
	while( value != 0 )
	{
		bitNumber = __builtin_clz( value );
		if ( m_apb2UseCounter[ bitNumber ] != 0 )
		{
			m_apb2UseCounter[ bitNumber ]--;
		}
		if ( m_apb2UseCounter[ bitNumber ] == 0 )
		{
			RCC_APB2PeriphClockCmd( 1<<bitNumber, DISABLE );
		}
		value -= 1<<bitNumber;
	}
}

inline void CRcc::increaseUseCount( uint32_t * useCounter, uint32_t value )
{
	uint32_t bitNumber = 0;
	while( value != 0 )
	{
		bitNumber = __builtin_clz( value );
		useCounter[ bitNumber ]++;
		value -= 1<<bitNumber;
	}
}

