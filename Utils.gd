class_name Utils


static func time_msec_to_string(value: int) -> String:
	var minute = 1000 * 60
	var second = 1000
	
	var mins = 0
	var secs = 0
	
	while value > minute:
		value -= minute
		mins += 1
	
	while value > second:
		value -= second
		secs += 1
	
	return "%dm %02ds %03dmsec" % [mins, secs, value]
