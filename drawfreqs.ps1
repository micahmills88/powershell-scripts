# y(t) = A * sin(2 * pi * f * t + p)
# A = amplitude
# f = frequency
# t = timestep or sample number
# p = phase

function Get-FreqArray {
    Param($A, $f, $p, [int]$size)

    #A is amplitude, f is frequency, p is phase, size is number of samples

    $twopi = [Math]::PI * 2.0
    $freqArray = @()
    foreach($i in 0..$size)
    {
        #generate an array of samples 1 sample at a time
        $sample = $A * [Math]::Sin($twopi * $f * ($i / $size) + $p)
        $freqArray += $sample
    }
    return $freqArray
}

function Get-PathPoints {
    Param([int]$yScale, [int]$height, [int]$width, $data)

    $ymult = $height / ($yScale * 2)
    $offset = $height / 2;
    $points = @()
    $x = 0;
    foreach($sample in $data)
    {
        #convert the samples into pixel coordinates
        $y = $offset - ($sample * $ymult)
        $point = New-Object System.Drawing.Point -ArgumentList $x,$y
        $points += $point
        $x++
    }
    return $points
}

function Add-SignalToBitmap {
    Param($bitmap, $signal, $scale, $color)

    #this function draws the samples as a path on top of a bitmap
    #scale is the x axis from -scale to +scale
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $pathpoints = Get-PathPoints -yScale $scale -height $($bitmap.Height) -width $($bitmap.Width) -data $signal
    $path.AddLines($pathpoints)

    [System.Drawing.Graphics]$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $pen = New-Object System.Drawing.Pen -ArgumentList $color,1
    $graphics.DrawPath($pen, $path)
    $graphics.Dispose()
    $pen.Dispose()
    $path.Dispose()

    return $bitmap
}

#create a windows form of a certain size (the window size needs to be slightly larger than the picturebox)
Add-Type -AssemblyName System.Windows.Forms
$form = New-Object System.Windows.Forms.Form
$form.Width = 1024
$form.Height = 512
$form.Text = "Frequency Graph"

#create a picturebox to hold our bitmap and display it on the form
$imageWidth = 1000
$imageHeight = 500
$picturebox = New-Object System.Windows.Forms.PictureBox
$picturebox.Width = $imageWidth
$picturebox.Height = $imageHeight
$picturebox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::AutoSize
$form.Controls.Add($picturebox)
#everything above is boilerplate to display the image


$freq1 = Get-FreqArray -A 1 -f 3 -p 0 -size $imageWidth
$freq2 = Get-FreqArray -A (1/3) -f 9 -p 0 -size $imageWidth
$freq3 = Get-FreqArray -A (1/5) -f 15 -p 0 -size $imageWidth
$freq4 = Get-FreqArray -A (1/7) -f 21 -p 0 -size $imageWidth
$freq5 = Get-FreqArray -A (1/9) -f 27 -p 0 -size $imageWidth
$freq6 = Get-FreqArray -A (1/11) -f 33 -p 0 -size $imageWidth

$freqSum = @()
foreach($i in 0..$imageWidth)
{
    $freqSum += ($freq1[$i] + $freq2[$i] + $freq3[$i] + $freq4[$i] + $freq5[$i + $freq6[$i]])
}

$bmp = New-Object System.Drawing.Bitmap -ArgumentList $imageWidth,$imageHeight
$bmp = Add-SignalToBitmap -bitmap $bmp -signal $freqSum -scale 2 -color $([System.Drawing.Color]::Blue)
#$bmp = Add-SignalToBitmap -bitmap $bmp -signal $freq2 -scale 10 -color $([System.Drawing.Color]::Red)

#$([System.Drawing.Bitmap]$bmp).Save($filepath)

#set the imagebox image to our bitmap then show the window
$picturebox.Image = $bmp
$form.ShowDialog();