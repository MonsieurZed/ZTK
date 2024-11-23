function IsEnabled {
    param (
        [string]$provider,
        [System.Object]$source
    )

    switch ($provider) {
        $app_dict.github {
            return $source.github
        }
        $app_dict.winget {
            return $source.winget
        }
        $app_dict.choco {
            return $source.choco
        }
        default {
            return $true
        }
    }
}

function Get_Group_Border {
    $groupBorder = New-Object Windows.Controls.Border
    $groupBorder.Margin = "2"
    $groupBorder.Background = '#222222'
    $groupBorder.Padding = "5"
    $groupBorder.CornerRadius = "5"
    # $groupBorder.Background = 'Green'
    return $groupBorder
}

function Get_Group_Panel {
    $groupPanel = New-Object Windows.Controls.StackPanel
    $groupPanel.Orientation = "Vertical"
    $groupPanel.Margin = "5"
    # $groupPanel.Background = 'Red'
    return $groupPanel
}

function GetTextblockHeader {
    param (
        [string]$text,
        [string]$iconUrl
    )

    $headerPanel = Get_Item_Panel

    if ($iconUrl) {
        try {
            $icon = Get_Icon_Panel $iconUrl
            [void]$headerPanel.Children.Add($icon)
        }
        catch {
            Write-Error "Failed to load header icon from $iconUrl"
        }
    }

    $headerText = New-Object Windows.Controls.TextBlock
    $headerText.Text = "$text :"
    $headerText.FontWeight = "Bold"
    $headerText.Foreground = "White"
    [void]$headerPanel.Children.Add($headerText)

    return $headerPanel
}

function Get_Item_Panel {
    $itemPanel = New-Object Windows.Controls.StackPanel
    $itemPanel.Orientation = "Horizontal"
    $itemPanel.Margin = "0,2,0,2"
    # $itemPanel.Background = 'Violet'
    return $itemPanel
}

function Get_Icon_Panel {
    param (
        [string]$iconUrl
    )
    $icon = New-Object Windows.Controls.Image
    $icon.Source = [Windows.Media.Imaging.BitmapImage]::new([Uri]::new($iconUrl))
    $icon.Width = 15
    $icon.Height = 15
    $icon.Margin = "2,0,2,0"
    $icon.Opacity = 0.9
    return $icon
}

function Get_Checkbox {
    param (
        [string]$name,
        [string]$description,
        [string]$provider,
        [System.Object]$source
    )
    $checkbox = New-Object Windows.Controls.CheckBox
    $checkbox.Content = $name
    $checkbox.Foreground = "#DDDDDD"
    $tooltip = New-Object Windows.Controls.ToolTip
    $tooltip.Content = "$description. [$provider]"
    $checkbox.ToolTip = $tooltip

    if ((IsEnabled -provider $provider -source $source) -eq $false) {
        $checkbox.IsEnabled = $false
        $checkbox.Foreground = "#555555"
    }

    return $checkbox
}

function Draw_Checkboxes {
    param (
        [object]$json,
        [System.Windows.Controls.Panel]$wrap_panel,
        [System.Object]$source
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
        
        $groupBorder = Get_Group_Border
        $groupPanel = Get_Group_Panel

        $header = GetTextblockHeader -text $app.title

        [void]$groupPanel.Children.Add($header)
    
        foreach ($item in $items) {

            $itemPanel = Get_Item_Panel

            if ($item.icon) {
                try {
                    $icon = Get_Icon_Panel -iconUrl $item.icon
                    [void]$itemPanel.Children.Add($icon)
                }
                catch {
                    Write-Error "Failed to load icon for $($item.name)"
                }
            }
            
            $checkbox = Get_Checkbox -name $item.name -description $item.description -provider $item.provider -source $source
            
            $item | Add-Member -MemberType NoteProperty -Name "checkbox" -Value $checkbox
            $item | Add-Member -MemberType NoteProperty -Name "browser" -Value $app.browser

            [void]$checkboxes.Add($item)

            [void]$itemPanel.Children.Add($checkbox)
            
            [void]$groupPanel.Children.Add($itemPanel)
        }

        $groupBorder.Child = $groupPanel

        [void]$wrap_panel.Children.Add($groupBorder)
    }
    return $checkboxes
}


function Draw_Buttons {
    param (
        [Object[]]$button_list,
        [Object]$wrap_panel
    )

    foreach ($category in $button_list) {
        $categoryName = $category[0]
        $items = $category[1]

        $groupBorder = Get_Group_Border
        $groupPanel = Get_Group_Panel
        $header = GetTextblockHeader -text $categoryName

        [void]$groupPanel.Children.Add($header)

        foreach ($item in $items) {           
            $name = $item[0]
            $action = $item[1]
            $description = $item[2]

            $button = New-Object Windows.Controls.Button
            $button.Content = $name
            $button.Foreground = "#DDDDDD"
            $button.Width = 120
            $button.Height = 30
            $button.Background = "#222222"
            $button.ToolTip = $description

            $button.Add_Click(
                $action
            )

            [void]$groupPanel.Children.Add($button)
        }

        $groupBorder.Child = $groupPanel

        [void]$wrap_panel.Children.Add($groupBorder)
    }
}

function Draw_Package {
    param (
        [object]$json,
        [System.Windows.Controls.ComboBox]$combo_box
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
