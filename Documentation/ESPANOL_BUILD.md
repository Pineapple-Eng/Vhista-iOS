# Documentación

En este documento encontrará las descripciones e instrucciones para construir y compilar el código fuente de **Vhista-iOS**. Es importante tener en cuenta que el código en este repositorio no tiene los archivos y llaves correspondientes a la conexión con los servidores. La persona que quiera recrear el proyecto completo debe seguir estas instrucciones. 

**De ninguna forma Vhista, Inc se hace responsable por el uso o consecuencias de uso del software dispuesto en este repositorio.** **Vhista, Inc, su nombre, su logo y cualquier información pertinente a la empresa estan protegidas por derechos de autor y no pueden ser usadas en ningun trabajo derivado de este código fuente.** **Se puede sin embargo, hacer atribuciones y agradecimientos a Vhista desde los trabajos derivados ❤️😊🇨🇴**
                
----


## Archivos del Proyecto

Este es un proyecto desarrollado para la plataforma **iOS**. Es un proyecto nativo escrito en **Swift 4.0**. Se recomienda ejecutar el proyecto con **macOS High Sierra** o superior, así como **Xcode 9.3** o superior. Los archivos del proyecto se presentan a continuación:

                
+ Pods <sub>(Carpeta de dependencias de [Cocoapods](https://cocoapods.org "Cocoapods"). Previamente subida al repositorio para evitar problemas de versionamiento)</sub>
+ Vhista.xcodeproj <sub>(Archivo ejecutable de Xcode, **No abrir este o las dependencias no se incluirán**)</sub>
+ Vhista.xcworkspace <sub>(Archivo ejecutable de la mesa de trabajo de Xcode, **Abrir este para ejecutar**)</sub>
+ Vhista
    * Archivos & Carpetas con código fuente
	* Assets.xcassets <sub>(Carpeta que almacena los recursos gráficos)</sub>
    * MLModels <sub>(Carpeta que contiene los distintos modelos de CoreML disponibles)</sub>
	* en.lproj <sub>(Carpeta con textos en inglés)</sub>
	* es-419.lproj <sub>(Carpeta con textos en español)</sub>
+ Podfile <sub>(Archivo con las dependencias del proyecto)</sub>
+ Podfile.lock <sub>(Archivo autogenerado que bloquea las versiones de las dependencias hasta un `pod update`)</sub>

## Configuración del Proyecto

Lo primero que se debe hacer para probar el proyecto es modificar el Identificador único de la aplicación. En Xcode, modificar `com.juandavidcruz.Vhista` por un identificador único y personal.

![App Identifier in Xcode](Assets/IDENTIFIER_XCODE.png?raw=true)

En caso de querer probar en dispositivo físico, u obtener un error de firma del proyecto. Asegurarse de crear una cuenta de desarrollador de Apple en [Apple Developer](https://developer.apple.com) y configurarla en Xcode. Asegurarse de seleccionar la cuenta y seleccionar la opción de firmar automaticamente el proyecto:

![App Signing in Xcode](Assets/SIGNING_XCODE.png?raw=true)

## Llaves y Cuentas Necesarias

Para poder utilizar y compilar Vhista, se debe crear una cuenta en [Amazon Web Services](https://aws.amazon.com) y allá se debe configurar todo para poder utilizar [AWS Rekognition](https://aws.amazon.com/rekognition/). Se recomienda revisar la [documentación completa de Rekognition](https://docs.aws.amazon.com/es_es/rekognition/latest/dg/what-is.html)

Se debe crear una cuenta en [Google Firebase](https://firebase.google.com) para poder utilizar los servicios de Notificaciones, Error Tracking y Analytics. Se recomienda revisar la [documentación completa de Firebase iOS](https://firebase.google.com/docs/ios/setup) para saber cómo obtener el archivo `GoogleService-Info.plist` que posteriormente se necesitará para compilar el proyecto.

Con la misma cuenta creada para Firebase, se debe activar el [Traductor de Google](https://cloud.google.com/translate/docs/) en [Google Cloud](https://cloud.google.com). Se recomienda leer la documentación completa de [cómo funciona el Traductor de Google](https://cloud.google.com/translate/docs/). Se debe crear la llave única que provee Google Cloud, y esta llave con acceso al traductor.

Con las cuentas creadas. Se debe crear un archivo llamado **SecureConstants.swift** dentro del proyecto descargado.

![App Constants in Xcode](Assets/CONSTANTS_XCODE.png?raw=true)

En este archivo se debe introducir el identificador que provee AWS y la llave de Google Cloud:
```swift
//
//  SecureConstants.swift
//  Vhista
//
//  Created by David Cruz on 5/19/18.
//  Copyright © 2018 juandavidcruz. All rights reserved.
//

import Foundation

let AWSPoolID = "YOUR_AWS_POOL_ID"
let AppleReceiptValidatorSecret = ""
let GoogleAPIKey = "YOUR_GOOGLE_API_KEY"
```

La llave de Apple, es solo si se desea tener subscripción en el servicio, y eso no se hace parte de la compilación del proyecto. Es independiente a cada caso y uso de este código fuente.

**EXISTEN VULNERABILIDADES SI SE COMPARTEN LAS LLAVES ANTES MENCIONADAS, MANTENERLAS EN SECRETO. PRONTO SE ACTUALIZARÁ ESTA SECCIÓN CON MÉTODOS MÁS SEGUROS DE CONECTARSE CON GOOGLE & AMAZON**

Recordar agregar el archivo de `GoogleService-Info.plist` antes de seguir con la compilación del proyecto:

![Google PLIST in Xcode](Assets/GOOGLE_XCODE.png?raw=true)

## Compilar el Proyecto

Con todos los archivos y todas las llaves presentes (Sin necesitar la de Apple para compilar). Correr el proyecto!

En caso de necesitar actualizar librerias o necesitar reinstalarlas. Seguir los pasos propuestos por Cocoapods:

Si aun no se tiene **Cocoapods** instalado en el Mac. Abrir **Terminal** y ejecutar:

```
sudo gem install cocoapods
```

Al instalar Cocoapods, desde terminal dirigirse a la carpeta donde esta el proyecto y especificamente donde se encuentra el archivo **Podfile**. Para agilizar este proceso, encontrar la carpeta con **Finder** e introducir en Terminal: `cd`, agregar un espacio y arrastrar la carpeta a la Terminal. Dar Enter.

Estando allí, si se quieren reinstalar las dependencias ejecutar el comando:

```
pod install
 ```
En caso de querer actualizar las librerias a la última versión ejecutar:

```
pod update
```
 **ACTUALIZAR LAS DEPENDENCIAS PUEDE REQUERIR MODIFICACIÓN EN EL CÓDIGO FUENTE PARA QUE COMPILE**
