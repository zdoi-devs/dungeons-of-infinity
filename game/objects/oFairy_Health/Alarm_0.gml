if(DB_Started || End) exit;

instance_create_layer(SparkleX + irandom_range(-10, 10), SparkleY + irandom_range(-10, 10), "ObjsHigher_Upper", oSparkle);

alarm[0] = SparkleDelay;