function IsEnabled {
    param (
        [string]$provider,
        [System.Object]$source
    )
    switch ($provider) {
        $conf_dict.github {
            return $source.github
        }
        $conf_dict.winget {
            return $source.winget
        }
        $conf_dict.choco {
            return $source.choco
        }
        default {
            return $true
        }
    }
}

function GetTextblockHeader {
    param (
        [string]$text,
        [string]$iconUrl
    )

    $headerPanel = New-Object Windows.Controls.StackPanel
    $headerPanel.style = $resources['Main_Stack_Title_StackPanel']

    if ($iconUrl) {
        try {
            $icon = New-Object Windows.Controls.Image
            $icon.Source = [Windows.Media.Imaging.BitmapImage]::new([Uri]::new($iconUrl))
            $icon.style = $resources['Main_Stack_Title_Image']
            [void]$headerPanel.Children.Add($icon)
        }
        catch {
            Write-Error "Failed to load header icon from $iconUrl"
        }
    }

    $headerText = New-Object Windows.Controls.TextBlock
    $headerText.style = $resources['Main_Stack_Title_TextBlock']
    $headerText.Text = "$text :"
    [void]$headerPanel.Children.Add($headerText)

    return $headerPanel
}

function Get_Checkbox {
    param (
        [string]$name,
        [string]$description,
        [string]$provider,
        [System.Object]$source
    )
    $tooltip = New-Object Windows.Controls.ToolTip
    $tooltip.Content = "$description. [$provider]"

    $checkbox = New-Object Windows.Controls.CheckBox
    $checkbox.Content = $name
    $checkbox.Style = $resources['Main_Stack_Checkbox']
    $checkbox.IsEnabled = IsEnabled -provider $provider -source $source
    $checkbox.ToolTip = $tooltip

    return $checkbox
}

function Draw_Checkboxes {
    param (
        [object]$json,
        [System.Windows.Controls.Panel]$wrap_panel,
        [System.Object]$source,
        [Windows.ResourceDictionary]$resources
    )
    $checkboxes = New-Object System.Collections.ArrayList

    foreach ($app in $json.list) {
        $items = $null

        if ($app.order -eq 'alpha') {
            [void]($items = $app.items | Sort-Object -Property name)
        }
        else {
            $items = $app.items
        }
        
        $groupBorder = New-Object Windows.Controls.Border
        $groupBorder.style = $resources['Main_Stack_Border']

        $groupPanel = New-Object Windows.Controls.StackPanel
        $groupPanel.style = $resources['Main_Stack_StackPanel']

        $header = GetTextblockHeader -text $app.title

        [void]$groupPanel.Children.Add($header)
    
        foreach ($item in $items) {

            $headerPanel = New-Object Windows.Controls.StackPanel
            $headerPanel.style = $resources['Main_Stack_Title_StackPanel']
            
            if ($item.icon) {
                try {
                    $icon = New-Object Windows.Controls.Image
                    $icon.Source = [Windows.Media.Imaging.BitmapImage]::new([Uri]::new($item.icon))
                    $icon.style = $resources['Main_Stack_Title_Image']
                    [void]$headerPanel.Children.Add($icon)
                }
                catch {
                    Write-Error "Failed to load icon for $($item.name)"
                }
            }
            
            $checkbox = Get_Checkbox -name $item.name -description $item.description -provider $item.provider -source $source
            
            $item | Add-Member -MemberType NoteProperty -Name "checkbox" -Value $checkbox
            $item | Add-Member -MemberType NoteProperty -Name "browser" -Value $app.browser

            [void]$checkboxes.Add($item)

            [void]$headerPanel.Children.Add($checkbox)
            
            [void]$groupPanel.Children.Add($headerPanel)
        }

        $groupBorder.Child = $groupPanel

        [void]$wrap_panel.Children.Add($groupBorder)
    }
    return $checkboxes
}


function Draw_Buttons {
    param (
        [Object[]]$button_list,
        [Object]$wrap_panel,
        [Windows.ResourceDictionary]$resources
    )

    foreach ($category in $button_list) {
        $categoryName = $category[0]
        $items = $category[1]

        $groupBorder = New-Object Windows.Controls.Border
        $groupBorder.style = $resources['Main_Stack_Border']

        $groupPanel = New-Object Windows.Controls.StackPanel
        $groupPanel.style = $resources['Main_Stack_StackPanel']

        $header = GetTextblockHeader -text $categoryName

        [void]$groupPanel.Children.Add($header)

        foreach ($item in $items) {           
            $name = $item[0]
            $action = $item[1]
            $description = $item[2]

            $button = New-Object Windows.Controls.Button
            $button.Content = $name
            $button.ToolTip = $description
            $button.Style = $resources['Main_Stack_Button']
            $button.Add_Click($action)

            [void]$groupPanel.Children.Add($button)
        }

        $groupBorder.Child = $groupPanel

        [void]$wrap_panel.Children.Add($groupBorder)
    }
}

function Draw_Package {
    param (
        [object]$json,
        [System.Windows.Controls.ComboBox]$combo_box,
        [Windows.ResourceDictionary]$resources
    )
    $packages = New-Object System.Collections.ArrayList

    foreach ($item in $json.list | Sort-Object -Property title) {

        $combo_box_item = New-Object Windows.Controls.ComboBoxItem
        $combo_box_item.Content = $item.title
        $combo_box_item.ToolTip = $item.description
        $combo_box_item.Tag = $item.Items 

        $item | Add-Member -MemberType NoteProperty -Name "packages" -Value $item

        [void]$combo_box.Items.Add($combo_box_item)
    }
    return $packages
}
