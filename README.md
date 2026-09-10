# PICkit_CMD
EN:

Scripts for quickly working with PIC microcontrollers using pk2cmd via the PICKit programmer (2/3/their clones) 

pk2cmd: https://github.com/jaka-fi/pk2cmd

The PK2DeviceFile.dat file was taken from PICkitminus: https://github.com/jaka-fi/PICkitminus

---------------------------------------------------------------------------------------

Usage:

Connect the programmer to your PC and the board, then select the desired .bat file.
The script will automatically detect the connected microcontroller and perform the necessary actions.

- Backup.bat - Creates a [backup] of the entire firmware.

- Backup_and_erase.bat - Creates a [backup] of the entire firmware and allows you to [erase ALL] memory (Program Memory + Config bits + EEPROM).

- Backup_and_erase_EEPROM.bat - Creates a [backup] of the entire firmware and allows you to [erase the EEPROM] memory (The EEPROM is filled with FF).

- Flash.bat — when you drag a [.hex] file onto [Flash.bat], it writes the firmware from the .hex file to the microcontroller. NO BACKUP IS CREATED!


============================================================================================

UA:

Скрипти для швидкої роботи з мікроконтролерами PIC за допомогою pk2cmd через програматор PICKit (2/3/їхні клони)

pk2cmd: https://github.com/jaka-fi/pk2cmd

Файл PK2DeviceFile.dat взято з PICkitminus: https://github.com/jaka-fi/PICkitminus

---------------------------------------------------------------------------------------

Використання:

Підключіть програматор до ПК та плати, а потім виберіть потрібний файл .bat.
Скрипт автоматично виявить підключений мікроконтролер і виконає необхідні дії.

- Backup.bat — створює [резервну копію] всієї прошивки.

- Backup_and_erase.bat — створює [резервну копію] всієї прошивки та дозволяє [очистити ВСЮ] пам'ять (Program Memory + Config bits + EEPROM).

- Backup_and_erase_EEPROM.bat — створює [резервну копію] всієї прошивки та дозволяє [очистити пам'ять EEPROM] (EEPROM заповняється FF).

- Flash.bat — коли ви перетягуєте файл [.hex] на [Flash.bat], він записує прошивку з .hex-файлу в мікроконтролер. БЕЗ СТВОРЕННЯ РЕЗЕРВНОЇ КОПІЇ!


