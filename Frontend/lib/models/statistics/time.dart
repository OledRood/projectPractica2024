class Time{
  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  Time( this.days,  this.hours, this.minutes, this.seconds);


  factory Time.fromJson(final Map<String, dynamic> json) => Time( json['days'], json['hours'], json['minutes'], json['seconds']);

}