;nyquist plug-in
;version 4
;codetype sal
;type process
;preview linear
;name "Algorithmic Dynamics Processor..."
;debugbutton disabled
;action "Applying Dynamics Processor..."
;author "Benjamin Pylko"
;copyright "Released under terms of the MIT License"

;control algorithm "Algorithm" choice "Power(|sound|^intensity),Root(intensity√|sound|),Exponential(intensity^|sound|),Negative Exponential(intensity^-|sound|),Logarithm(log_intensity(|sound|)),Pulse Width Modulation(intensity/10)" 0
;control intensity "Effect Intensity (Algorithm Parameter)" float "" 2 0.1 10
;control dry "Wet/Dry Mix" float "" 1 -1 1

define function ADPWetDry(_wet, _dry)
	return mult(_wet, 1 - abs(dry)) + mult(_dry, dry)

define function ADPSign(_wet, _dry)
	return ADPWetDry(_wet, mult(_dry, quantize(diff(mult(_wet, 0.5), 0.5), 1) + quantize(diff(0.5, mult(_wet, -0.5)), 1)))

define function ADPPower(_sound)
	return ADPSign(_sound, s-exp(s-log(s-abs(_sound)) * intensity))

define function ADPRoot(_sound)
	return ADPSign(_sound, s-exp(mult(s-log(s-abs(_sound)), 1 / intensity)))

define function ADPExp(_sound)
	return ADPSign(_sound, s-exp(s-abs(_sound) * log(intensity)) - 1)

define function ADPNegExp(_sound)
	return ADPSign(_sound, 1 - s-exp(mult(s-abs(_sound) * log(intensity), - 1)))

define function ADPLog(_sound)
	return ADPSign(_sound, mult(s-log(s-abs(_sound) + 1), 1 / log(intensity)))

define function ADPPWM(_sound)
	return ADPSign(_sound, intensity / 10);

define function ADP(_sound)
	if (algorithm = 0) then
		return ADPPower(_sound)
	else if (algorithm = 1) then
		return ADPRoot(_sound)
	else if (algorithm = 2) then
		return ADPExp(_sound)
	else if (algorithm = 3) then
		return ADPNegExp(_sound)
	else if (algorithm = 4) then
		return ADPLog(_sound)
	else if (algorithm = 5) then
		return ADPPWM(_sound)

if get(quote(*track*), quote(channels)) > 2 then
	return "This plugin cannot operate on more than 2 channels"
else
	return multichan-expand(quote(ADP), *track*)
