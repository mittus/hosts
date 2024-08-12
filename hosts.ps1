param (
    [string]$Action,
    [string]$Hostname,
    [string]$IPAddress,
    [string]$Other
)

$hostsPath = "C:\Windows\System32\drivers\etc\hosts"

# Функция для добавления новой записи
function AddHost {
    param (
        [string]$Hostname,
        [string]$IPAddress
    )

    # Формат новой записи
    $newEntry = "$IPAddress`t$Hostname"

    # Чтение текущего содержимого файла hosts
    $hostsContent = [System.IO.File]::ReadAllLines($hostsPath)

    # Проверка, существует ли запись
    $entryExists = $hostsContent -contains $newEntry

    if (-not $entryExists) {
        # Добавление новой записи в файл hosts
        Add-Content -Path $hostsPath -Value $newEntry
        Write-Output "Запись добавлена: $newEntry"
        # Сброс кеша DNS
        ipconfig /flushdns | Out-Null
        Write-Output "Кеш DNS сброшен."
    } else {
        Write-Output "Запись уже существует: $newEntry"
    }
}

# Функция для удаления записи
function RemoveHost {
    param (
        [string]$Hostname
    )

    $hostsContent = [System.IO.File]::ReadAllLines($hostsPath)

    # Флаг для проверки, была ли найдена запись для удаления
    $found = $false

    # Инициализация новой коллекции для записи в файл
    $newHostsContent = @()

    # Формирование нового содержимого файла hosts без строк с указанным хостом
    foreach ($line in $hostsContent) {
        if ($line -match "^\s*([^#]+\S+)\s+$Hostname\s*$") {
            Write-Output "Запись удалена: $line"
            $found = $true
        } else {
            $newHostsContent += $line
        }
    }

    if (-not $found) {
        Write-Output "Запись не найдена: $Hostname"
    } else {
        [System.IO.File]::WriteAllLines($hostsPath, $newHostsContent)
    }
}

# Функция для вывода текущих записей, отсортированных по окончаниям .local и .docker.local
function ShowHosts {
    param (
        [string]$Other
    )

    # Чтение текущего содержимого файла hosts
    $hostsContent = [System.IO.File]::ReadAllLines($hostsPath)

    # Инициализация коллекций для записей .local и .docker.local
    $localEntries = @()
    $dockerLocalEntries = @()
    $otherEntries = @()

    # Формирование коллекций записей по критериям .local и .docker.local
    foreach ($line in $hostsContent) {
        if ($line -match "^\s*([^#]+\S+)\s+(\S+)\.docker\.local\s*$") {
            $dockerLocalEntries += $line
        } elseif ($line -match "^\s*([^#]+\S+)\s+(\S+)\.local\s*$") {
            $localEntries += $line
        } elseif ($Other -and $line -notmatch "^\s*#") {
            $otherEntries += $line
        }
    }

    # Сортировка записей по алфавиту
    $sortedDockerLocalEntries = $dockerLocalEntries | Sort-Object
    $sortedLocalEntries = $localEntries | Sort-Object

    if (-not $Other) {
        Write-Output "Записи local:"
        Write-Output $sortedLocalEntries

        Write-Output "Записи docker:"
        Write-Output $sortedDockerLocalEntries
    } else {
        Write-Output "Прочие записи:"
        Write-Output $otherEntries
    }
}

# Определение действия и его выполнение
switch ($Action) {
    "add" {
        AddHost -Hostname $Hostname -IPAddress $IPAddress
    }
    "remove" {
        RemoveHost -Hostname $Hostname
    }
    "show" {
        ShowHosts -Other $Other
    }
    default {
        Write-Output "Неподдерживаемое действие. Доступные действия: 'add', 'remove', 'show'."
    }
}
