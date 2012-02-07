################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Utilities/STM3210B_EVAL/stm3210b_eval.c \
../Utilities/STM3210B_EVAL/stm3210b_eval_lcd.c 

OBJS += \
./Utilities/STM3210B_EVAL/stm3210b_eval.o \
./Utilities/STM3210B_EVAL/stm3210b_eval_lcd.o 

C_DEPS += \
./Utilities/STM3210B_EVAL/stm3210b_eval.d \
./Utilities/STM3210B_EVAL/stm3210b_eval_lcd.d 


# Each subdirectory must supply rules for building sources it contributes
Utilities/STM3210B_EVAL/%.o: ../Utilities/STM3210B_EVAL/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM Sourcery Linux GCC C Compiler'
	arm-none-eabi-gcc -DSTM32F10X_MD -DUSE_STDPERIPH_DRIVER -I"/home/artur/eclipseProjects/cyclingEfficiency/Libraries/STM32F10x_StdPeriph_Driver/inc" -I"/home/artur/eclipseProjects/cyclingEfficiency/Utilities/STM32_EVAL" -I"/home/artur/eclipseProjects/cyclingEfficiency/Libraries/CMSIS/CM3/CoreSupport" -I"/home/artur/eclipseProjects/cyclingEfficiency/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x" -O0 -Wall -Wa,-adhlns="$@.lst" -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -mcpu=cortex-m3 -mthumb -g3 -gdwarf-2 -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

