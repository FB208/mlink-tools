# Set UTF-8 encoding
$OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Symlink Manager'
$form.Size = New-Object System.Drawing.Size(800,600)
$form.StartPosition = 'CenterScreen'

# Create DataGridView
$dataGridView = New-Object System.Windows.Forms.DataGridView
$dataGridView.Location = New-Object System.Drawing.Point(10,10)
$dataGridView.Size = New-Object System.Drawing.Size(760,450)
$dataGridView.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill
$dataGridView.AllowUserToAddRows = $false
$dataGridView.AllowUserToDeleteRows = $false
$dataGridView.MultiSelect = $false
$dataGridView.SelectionMode = 'FullRowSelect'

# Add columns
$sourceColumn = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$sourceColumn.Name = 'sourcePath'
$sourceColumn.HeaderText = 'Source Path'
$dataGridView.Columns.Add($sourceColumn)

$targetColumn = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$targetColumn.Name = 'targetPath'
$targetColumn.HeaderText = 'Target Path'
$dataGridView.Columns.Add($targetColumn)

$typeColumn = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$typeColumn.Name = 'type'
$typeColumn.HeaderText = 'Type'
$dataGridView.Columns.Add($typeColumn)

$timeColumn = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$timeColumn.Name = 'createTime'
$timeColumn.HeaderText = 'Create Time'
$dataGridView.Columns.Add($timeColumn)

# Create buttons
$addButton = New-Object System.Windows.Forms.Button
$addButton.Location = New-Object System.Drawing.Point(10,470)
$addButton.Size = New-Object System.Drawing.Size(100,30)
$addButton.Text = 'Add'

$deleteButton = New-Object System.Windows.Forms.Button
$deleteButton.Location = New-Object System.Drawing.Point(120,470)
$deleteButton.Size = New-Object System.Drawing.Size(100,30)
$deleteButton.Text = 'Delete'

# Config file path
$configPath = Join-Path $PSScriptRoot 'symlinks.json'

# Load existing symlinks
function LoadSymlinks {
    # Create config file if it doesn't exist
    if (-not (Test-Path $configPath)) {
        $initialConfig = @{
            symlinks = @()
        } | ConvertTo-Json
        $initialConfig | Set-Content $configPath -Encoding UTF8
    }

    # Load symlinks from config file
    $config = Get-Content $configPath -Encoding UTF8 | ConvertFrom-Json
    $dataGridView.Rows.Clear()
    foreach ($link in $config.symlinks) {
        $dataGridView.Rows.Add($link.sourcePath, $link.targetPath, $link.type, $link.createTime)
    }
}

# Save symlinks config
function SaveSymlinks {
    $symlinks = @{
        symlinks = @()
    }
    foreach ($row in $dataGridView.Rows) {
        $symlink = @{
            sourcePath = $row.Cells[0].Value
            targetPath = $row.Cells[1].Value
            type = $row.Cells[2].Value
            createTime = $row.Cells[3].Value
        }
        $symlinks.symlinks += $symlink
    }
    $symlinks | ConvertTo-Json | Set-Content $configPath -Encoding UTF8
}

# Add symlink event handler
$addButton.Add_Click({
    $addForm = New-Object System.Windows.Forms.Form
    $addForm.Text = 'Add Symlink'
    $addForm.Size = New-Object System.Drawing.Size(600,250)
    $addForm.StartPosition = 'CenterScreen'

    # Source path input
    $sourceLabel = New-Object System.Windows.Forms.Label
    $sourceLabel.Location = New-Object System.Drawing.Point(10,20)
    $sourceLabel.Size = New-Object System.Drawing.Size(100,20)
    $sourceLabel.Text = 'Source:'
    
    $sourceTextBox = New-Object System.Windows.Forms.TextBox
    $sourceTextBox.Location = New-Object System.Drawing.Point(120,20)
    $sourceTextBox.Size = New-Object System.Drawing.Size(350,20)
    
    $sourceBrowseButton = New-Object System.Windows.Forms.Button
    $sourceBrowseButton.Location = New-Object System.Drawing.Point(480,20)
    $sourceBrowseButton.Size = New-Object System.Drawing.Size(80,20)
    $sourceBrowseButton.Text = 'Browse'

    # Target path input
    $targetLabel = New-Object System.Windows.Forms.Label
    $targetLabel.Location = New-Object System.Drawing.Point(10,60)
    $targetLabel.Size = New-Object System.Drawing.Size(100,20)
    $targetLabel.Text = 'Target:'
    
    $targetTextBox = New-Object System.Windows.Forms.TextBox
    $targetTextBox.Location = New-Object System.Drawing.Point(120,60)
    $targetTextBox.Size = New-Object System.Drawing.Size(350,20)
    
    $targetBrowseButton = New-Object System.Windows.Forms.Button
    $targetBrowseButton.Location = New-Object System.Drawing.Point(480,60)
    $targetBrowseButton.Size = New-Object System.Drawing.Size(80,20)
    $targetBrowseButton.Text = 'Browse'

    # Confirm button
    $confirmButton = New-Object System.Windows.Forms.Button
    $confirmButton.Location = New-Object System.Drawing.Point(250,150)
    $confirmButton.Size = New-Object System.Drawing.Size(100,30)
    $confirmButton.Text = 'OK'

    # Browse button events
    $sourceBrowseButton.Add_Click({
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $result = $folderBrowser.ShowDialog()
        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            $sourceTextBox.Text = $folderBrowser.SelectedPath
        }
    })

    $targetBrowseButton.Add_Click({
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $result = $folderBrowser.ShowDialog()
        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            $targetTextBox.Text = $folderBrowser.SelectedPath
        }
    })

    # Confirm button event
    $confirmButton.Add_Click({
        $sourcePath = $sourceTextBox.Text
        $targetPath = $targetTextBox.Text
        
        if ([string]::IsNullOrEmpty($sourcePath) -or [string]::IsNullOrEmpty($targetPath)) {
            [System.Windows.Forms.MessageBox]::Show('Please input both paths', 'Error')
            return
        }

        try {
            # Create symlink
            New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath -Force
            
            # Add to grid
            $type = if (Test-Path -Path $sourcePath -PathType Container) { 'Directory' } else { 'File' }
            $dataGridView.Rows.Add($sourcePath, $targetPath, $type, (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
            
            # Save config
            SaveSymlinks
            
            $addForm.Close()
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show('Failed to create symlink: ' + $_.Exception.Message, 'Error')
        }
    })

    $addForm.Controls.AddRange(@($sourceLabel, $sourceTextBox, $sourceBrowseButton,
                                $targetLabel, $targetTextBox, $targetBrowseButton,
                                $confirmButton))
    $addForm.ShowDialog()
})

# Delete symlink event handler
$deleteButton.Add_Click({
    $selectedRow = $dataGridView.SelectedRows[0]
    if ($selectedRow) {
        $targetPath = $selectedRow.Cells[1].Value
        $result = [System.Windows.Forms.MessageBox]::Show('Are you sure to delete this symlink?', 'Confirm',
            [System.Windows.Forms.MessageBoxButtons]::YesNo)
        
        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            try {
                # Delete symlink without confirmation prompt and handle subdirectories
                Remove-Item -Path $targetPath -Force -Confirm:$false -Recurse
                
                # Remove from grid
                $dataGridView.Rows.Remove($selectedRow)
                
                # Save config
                SaveSymlinks
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show('Failed to delete symlink: ' + $_.Exception.Message, 'Error')
            }
        }
    }
    else {
        [System.Windows.Forms.MessageBox]::Show('Please select a symlink to delete', 'Info')
    }
})

# Load controls
$form.Controls.AddRange(@($dataGridView, $addButton, $deleteButton))

# Load existing symlinks
LoadSymlinks

# Show form
$form.ShowDialog()