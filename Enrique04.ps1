# ============================================================================
# PREPARAR ENTORNO
# PARTE IMPLEMENTADA DE IA CLAUDE
# ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
# ============================================================================
param(
    [switch]$DryRun
)

$notaFinal = 0
$errores = @()

# Mostrar modo de ejecución
if ($DryRun) {
    Write-Host "`n========================================"
    Write-Host "   MODO DRY-RUN ACTIVADO"
    Write-Host "   (No se harán cambios reales)"
    Write-Host "========================================`n"
}

# Verificar que existe el script a evaluar
if (-not (Test-Path ".\Eneko03.ps1")) {
    Write-Host "ERROR: No se encuentra el script .\1.ps1"
    exit
}

Write-Host "Preparando entorno de pruebas..."

if ($DryRun) {

    Write-Host "[DRY-RUN] Se limpiarian los directorios C:\Logs y C:\Users\proyecto"
    Write-Host "[DRY-RUN] Se crearian 5 usuarios de prueba (user01-user05)"
    Write-Host "[DRY-RUN] Se crearian carpetas y archivos de prueba"

} else {

    # Limpiar y crear directorios
    "C:\Logs", "C:\Users\proyecto" | ForEach-Object {
        if (Test-Path $_) { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }
        New-Item -Path $_ -ItemType Directory -Force | Out-Null
    }

    # Crear usuarios de prueba con carpetas y archivos
    $usuarios = @(
        @{nombre="Juan"; ape1="Garcia"; ape2="Lopez"; login="user01"}
        @{nombre="Maria"; ape1="Martinez"; ape2="Sanchez"; login="user02"}
        @{nombre="Pedro"; ape1="Rodriguez"; ape2="Fernandez"; login="user03"}
        @{nombre="Ana"; ape1="Lopez"; ape2="Gomez"; login="user04"}
        @{nombre="Luis"; ape1="Sanchez"; ape2="Ruiz"; login="user05"}
    )

    foreach ($u in $usuarios) {
        $pass = ConvertTo-SecureString "Pass123!" -AsPlainText -Force
        try {
            New-ADUser -Name $u.login -GivenName $u.nombre -Surname "$($u.ape1) $($u.ape2)" `
                       -SamAccountName $u.login -UserPrincipalName "$($u.login)@dominio.local" `
                       -AccountPassword $pass -Enabled $true -ErrorAction SilentlyContinue
        } catch {}
        
        $trabajo = "C:\Users\$($u.login)\trabajo"
        New-Item -Path $trabajo -ItemType Directory -Force | Out-Null
        1..3 | ForEach-Object { "Archivo $_" | Out-File "$trabajo\doc$_.txt" }
    }
}

Write-Host "Entorno preparado. Iniciando pruebas...`n"
# ============================================================================
# ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
# PARTE IMPLEMENTADA DE IA CLAUDE
# ============================================================================
# ============================================================================
# FUNCIONES DE PRUEBA
# COMPOSICION DE IA Y ESCRITO
# ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
# ============================================================================

function Test-1-EliminarUsuario {

    Write-Host "`nPRUEBA 1: Eliminar usuario existente"
    
    if ($DryRun) {

        Write-Host "[DRY-RUN] Se crearía archivo test1.txt con datos de user01"
        Write-Host "[DRY-RUN] Se ejecutaría el script de bajas"
        Write-Host "[DRY-RUN] Se verificaría la eliminación de user01"
        Write-Host "SIMULADA: Usuario eliminado correctamente"
        $script:notaFinal++
    
    } else {

        $archivo = ".\test1.txt"
        "Juan:Garcia:Lopez:user01" | Out-File $archivo
        
        powershell.exe -ExecutionPolicy Bypass -File ".\Eneko03.ps1" $archivo | Out-Null
        Start-Sleep -Seconds 3
        
        $existe = try { Get-ADUser -Identity "user01" -ErrorAction Stop; $true } catch { $false }
        
        if (-not $existe) {
            Write-Host "PASADA: Usuario eliminado correctamente"
            $script:notaFinal++
        
	} else {
            Write-Host "FALLIDA: El usuario no fue eliminado"
            $script:errores += "Prueba 1 - Esperado: usuario eliminado, Obtenido: usuario existe"
        }
        
        Remove-Item $archivo -Force -ErrorAction SilentlyContinue
    }
}

function Test-2-MoverArchivos {
    Write-Host "`nPRUEBA 2: Mover archivos al directorio de proyecto"
    
        if ($DryRun) {
        	Write-Host "[DRY-RUN] Se ejecutaría baja de user02"
        	Write-Host "[DRY-RUN] Se verificaría movimiento de archivos a C:\Users\proyecto\user02"
        	Write-Host "SIMULADA: Archivos movidos correctamente (3 archivos)"
        	$script:notaFinal++
    
	} else {
        	$archivo = ".\test2.txt"
        	"Maria:Martinez:Sanchez:user02" | Out-File $archivo
        
       		powershell.exe -ExecutionPolicy Bypass -File ".\Eneko03.ps1" $archivo | Out-Null
        	Start-Sleep -Seconds 3
        
        	$dirDestino = "C:\Users\proyecto\user02"
        
        	if (Test-Path $dirDestino) {
            		$cantidadArchivos = (Get-ChildItem -Path $dirDestino -File -ErrorAction SilentlyContinue).Count
            
            		if ($cantidadArchivos -ge 3) {
                		Write-Host "PASADA: Archivos movidos correctamente ($cantidadArchivos archivos)"
                		$script:notaFinal++
            		
			} else {
                		Write-Host "FALLIDA: No se movieron todos los archivos"
                		$script:errores += "Prueba 2 - Esperado: 3 archivos, Obtenido: $cantidadArchivos archivos"
            		}
               
		} else {
            		Write-Host "FALLIDA: No se creó el directorio de destino"
            		$script:errores += "Prueba 2 - Esperado: directorio creado, Obtenido: directorio no existe"
        }
        
        Remove-Item $archivo -Force -ErrorAction SilentlyContinue
    }
}

function Test-3-GeneracionLog {
    Write-Host "`nPRUEBA 3: Generación de log correcto"
    
    if ($DryRun) {
        Write-Host "[DRY-RUN] Se ejecutaría baja de user03"
        Write-Host "[DRY-RUN] Se verificaría existencia de C:\Logs\bajas.log"
        Write-Host "SIMULADA: Log generado con información del usuario"
        $script:notaFinal++
    
    } else {
        $archivo = ".\test3.txt"
        "Pedro:Rodriguez:Fernandez:user03" | Out-File $archivo
        
        powershell.exe -ExecutionPolicy Bypass -File ".\Eneko03.ps1" $archivo | Out-Null
        Start-Sleep -Seconds 3
        
        if (Test-Path "C:\Logs\bajas.log") {
            $contenido = Get-Content "C:\Logs\bajas.log" -Raw
            
            if ($contenido -match "user03") {
                Write-Host "PASADA: Log generado con información del usuario"
                $script:notaFinal++
            
	    } else {
                Write-Host "FALLIDA: El log no contiene información del usuario"
                $script:errores += "Prueba 3 - Esperado: log con user03, Obtenido: log sin user03"
            }
        
	} else {
            Write-Host "FALLIDA: No se generó archivo de log"
            $script:errores += "Prueba 3 - Esperado: archivo de log, Obtenido: archivo no existe"
        }
        
        Remove-Item $archivo -Force -ErrorAction SilentlyContinue
    }
}

function Test-4-LogErrores {
    Write-Host "`nPRUEBA 4: Usuario no existente registrado como error"
    
    if ($DryRun) {
        Write-Host "[DRY-RUN] Se intentaría dar de baja usuario inexistente"
        Write-Host "[DRY-RUN] Se verificaría C:\Logs\bajaserror.log"
        Write-Host "SIMULADA: Error registrado en log de errores"
        $script:notaFinal++
    
    } else {
        $archivo = ".\test4.txt"
        "Inexistente:Apellido:Segundo:noexiste999" | Out-File $archivo
        
        powershell.exe -ExecutionPolicy Bypass -File ".\Eneko03.ps1" $archivo | Out-Null
        Start-Sleep -Seconds 3
        
        if (Test-Path "C:\Logs\bajaserror.log") {
            $contenido = Get-Content "C:\Logs\bajaserror.log" -Raw
            
            if ($contenido -match "noexiste999") {
                Write-Host "PASADA: Error registrado en log de errores"
                $script:notaFinal++
            
	    } else {
                Write-Host "FALLIDA: Error no registrado"
                $script:errores += "Prueba 4 - Esperado: error en log, Obtenido: sin registro de error"
            }
        
	} else {
            Write-Host "FALLIDA: No hay archivo de log de errores"
            $script:errores += "Prueba 4 - Esperado: log de errores, Obtenido: archivo no existe"
        }
        
        Remove-Item $archivo -Force -ErrorAction SilentlyContinue
    }
}

function Test-5-EliminacionCompleta {

    Write-Host "`nPRUEBA 5: Verificar eliminación completa de usuario"
    
    if ($DryRun) {

        Write-Host "[DRY-RUN] Se ejecutaría baja de user04"
        Write-Host "[DRY-RUN] Se verificaría eliminación de AD"
        Write-Host "SIMULADA: Usuario eliminado del sistema"
        $script:notaFinal++

    } else {

        $archivo = ".\test5.txt"
        "Ana:Lopez:Gomez:user04" | Out-File $archivo
        
        powershell.exe -ExecutionPolicy Bypass -File ".\Eneko03.ps1" $archivo | Out-Null
        Start-Sleep -Seconds 3
        
        $existe = try { 

                    Get-ADUser -Identity "user04" -ErrorAction Stop; 
                    $true 

                  } catch {

                    $false 
                  }
        
        if (-not $existe) {

            Write-Host "PASADA: Usuario eliminado del sistema"
            $script:notaFinal++

        } else {

            Write-Host "FALLIDA: Usuario sigue existiendo"
            $script:errores += "Prueba 5 - Esperado: usuario eliminado, Obtenido: usuario existe"

        }
        
        Remove-Item $archivo -Force -ErrorAction SilentlyContinue
    }
}

function Test-6-ConservacionArchivos {
    Write-Host "`nPRUEBA 6: Verificar conservación de todos los archivos"
    
    if ($DryRun) {
        Write-Host "[DRY-RUN] Se ejecutaría baja de user05"
        Write-Host "[DRY-RUN] Se verificaría conservación de archivos"
        Write-Host "SIMULADA: Todos los archivos conservados (3/3)"
        $script:notaFinal++
    
    } else {
        $dirOrigen = "C:\Users\user05\trabajo"
        $archivosOriginales = (Get-ChildItem -Path $dirOrigen -File).Count
        
        $archivo = ".\test6.txt"
        "Luis:Sanchez:Ruiz:user05" | Out-File $archivo
        
        powershell.exe -ExecutionPolicy Bypass -File ".\Eneko03.ps1" $archivo | Out-Null
        Start-Sleep -Seconds 3
        
        $dirDestino = "C:\Users\proyecto\user05"
        
        if (Test-Path $dirDestino) {
            $archivosDestino = (Get-ChildItem -Path $dirDestino -File -ErrorAction SilentlyContinue).Count
            
            if ($archivosDestino -eq $archivosOriginales) {
                Write-Host "PASADA: Todos los archivos conservados ($archivosDestino/$archivosOriginales)"
                $script:notaFinal++
            
	    } else {
                Write-Host "FALLIDA: Se perdieron archivos"
                $script:errores += "Prueba 6 - Esperado: $archivosOriginales archivos, Obtenido: $archivosDestino archivos"
            }
        
	} else {
            Write-Host "FALLIDA: Directorio destino no existe"
            $script:errores += "Prueba 6 - Esperado: archivos en destino, Obtenido: directorio no existe"
        }
        
        Remove-Item $archivo -Force -ErrorAction SilentlyContinue
    }
}

function Test-7-FechaHoraLog {
    Write-Host "`nPRUEBA 7: Verificar fecha y hora en logs"
    
    if ($DryRun) {
        Write-Host "[DRY-RUN] Se verificaría formato de fecha/hora en logs"
        Write-Host "SIMULADA: Log contiene fecha/hora"
        $script:notaFinal++
    
    } else {
        if (Test-Path "C:\Logs\bajas.log") {
            $contenido = Get-Content "C:\Logs\bajas.log" -Raw
            $tieneFecha = $contenido -match '\d{2}/\d{2}/\d{4}' -or $contenido -match '\d{1,2}:\d{2}'
            
            if ($tieneFecha) {
                Write-Host "PASADA: Log contiene fecha/hora"
                $script:notaFinal++
            
	    } else {
                Write-Host "FALLIDA: Log no contiene fecha/hora"
                $script:errores += "Prueba 7 - Esperado: fecha/hora en log, Obtenido: sin fecha/hora"
            }
        
	} else {
            Write-Host "FALLIDA: No existe archivo de log"
            $script:errores += "Prueba 7 - Esperado: log con fecha, Obtenido: archivo no existe"
        }
    }
}

function Test-8-ContadorArchivos {
    Write-Host "`nPRUEBA 8: Verificar que log contiene contador de archivos"
    
    if ($DryRun) {
        Write-Host "[DRY-RUN] Se verificaría contador en logs"
        Write-Host "SIMULADA: Log contiene contador de archivos"
        $script:notaFinal++
    
    } else {
        if (Test-Path "C:\Logs\bajas.log") {
            $contenido = Get-Content "C:\Logs\bajas.log" -Raw
            
            if ($contenido -match "TOTAL FICHEROS") {
                Write-Host "PASADA: Log contiene contador de archivos"
                $script:notaFinal++
            
	    } else {
                Write-Host "FALLIDA: Log no contiene contador"
                $script:errores += "Prueba 8 - Esperado: contador en log, Obtenido: sin contador"
            }
        
	} else {
            Write-Host "FALLIDA: No existe archivo de log"
            $script:errores += "Prueba 8 - Esperado: log con contador, Obtenido: archivo no existe"
        }
    }
}

function Test-9-EliminacionPerfil {
    Write-Host "`nPRUEBA 9: Verificar eliminación de perfil local"
    
    if ($DryRun) {
        Write-Host "[DRY-RUN] Se crearia usuario temporal"
        Write-Host "[DRY-RUN] Se verificaria eliminación de perfil"
        Write-Host "SIMULADA: Perfil local eliminado"
        $script:notaFinal++
    
    } else {
        $pass = ConvertTo-SecureString "Pass123!" -AsPlainText -Force
        New-ADUser -Name "tempuser" -SamAccountName "tempuser" `
                   -AccountPassword $pass -Enabled $true -ErrorAction SilentlyContinue
        
        $perfilTemp = "C:\Users\tempuser"
        New-Item -Path "$perfilTemp\trabajo" -ItemType Directory -Force | Out-Null
        "Test" | Out-File "$perfilTemp\trabajo\test.txt"
        
        $archivo = ".\test9.txt"
        "Temp:User:Test:tempuser" | Out-File $archivo
        
        powershell.exe -ExecutionPolicy Bypass -File ".\Eneko03.ps1" $archivo | Out-Null
        Start-Sleep -Seconds 3
        
        if (-not (Test-Path $perfilTemp)) {
            Write-Host "PASADA: Perfil local eliminado"
            $script:notaFinal++
        
	
	} else {
            Write-Host "FALLIDA: Perfil local no eliminado"
            $script:errores += "Prueba 9 - Esperado: perfil eliminado, Obtenido: perfil existe"
        }
        
        Remove-Item $archivo -Force -ErrorAction SilentlyContinue
    }
}

function Test-10-CambioPropietario {
    Write-Host "`nPRUEBA 10: Verificar cambio de propietario de archivos"
    
    if ($DryRun) {
        Write-Host "[DRY-RUN] Se crearia usuario de prueba"
        Write-Host "[DRY-RUN] Se verificaria cambio de propietario"
        Write-Host "SIMULADA: Propietario cambiado a Administrador"
        $script:notaFinal++
    
    } else {
        $pass = ConvertTo-SecureString "Pass123!" -AsPlainText -Force
        New-ADUser -Name "ownertest" -SamAccountName "ownertest" `
                   -AccountPassword $pass -Enabled $true -ErrorAction SilentlyContinue
        
        $perfilOwner = "C:\Users\ownertest"
        New-Item -Path "$perfilOwner\trabajo" -ItemType Directory -Force | Out-Null
        "Test owner" | Out-File "$perfilOwner\trabajo\test.txt"
        
        $archivo = ".\test10.txt"
        "Owner:Test:User:ownertest" | Out-File $archivo
        
        powershell.exe -ExecutionPolicy Bypass -File ".\Eneko03.ps1" $archivo | Out-Null
        Start-Sleep -Seconds 3
        
        $dirProyecto = "C:\Users\proyecto\ownertest"
        
        if (Test-Path $dirProyecto) {
            $acl = Get-Acl $dirProyecto
            
            if ($acl.Owner -match "Administrador") {
                Write-Host "PASADA: Propietario cambiado a Administrador"
                $script:notaFinal++
            
	    } else {
                Write-Host "FALLIDA: Propietario no cambiado"
                $script:errores += "Prueba 10 - Esperado: propietario Administrador, Obtenido: $($acl.Owner)"
            }
        
	} else {
            Write-Host "FALLIDA: No se creo carpeta de proyecto"
            $script:errores += "Prueba 10 - Esperado: carpeta creada, Obtenido: carpeta no existe"
        }
        
        Remove-Item $archivo -Force -ErrorAction SilentlyContinue
    }
}
# ============================================================================
# ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
# COMPOSICION DE IA Y ESCRITO
# ============================================================================


# ============================================================================
# EJECUCIÓN PRINCIPAL
# COMPOSICION HUMANA
# ============================================================================

# Ejecutar todas las pruebas
Test-1-EliminarUsuario
Test-2-MoverArchivos
Test-3-GeneracionLog
Test-4-LogErrores
Test-5-EliminacionCompleta
Test-6-ConservacionArchivos
Test-7-FechaHoraLog
Test-8-ContadorArchivos
Test-9-EliminacionPerfil
Test-10-CambioPropietario

# ============================================================================
# MOSTRAR RESULTADOS FINALES
# AYUDA DE LA IA PARA VARIABLE DE COLOR
# ============================================================================

Write-Host "============================================"
Write-Host "RESULTADOS FINALES"
Write-Host "============================================"

if ($DryRun) {
    Write-Host "NOTA FINAL (SIMULADA): $notaFinal / 10"
    Write-Host "NOTA: Esto es una simulación. Ejecuta sin -DryRun para hacer las pruebas reales."

} else {
    $colorNota = if($notaFinal -ge 5){"Green"}else{"Red"}
    Write-Host "NOTA FINAL: $notaFinal / 10" -ForegroundColor $colorNota

    if ($errores.Count -gt 0) {
        Write-Host "ERRORES DETECTADOS:"
        foreach ($error in $errores) {
            Write-Host "- $error"
        }
    
    } else {
    	Write-Host "¡Todas las pruebas pasadas correctamente!"
    }
}