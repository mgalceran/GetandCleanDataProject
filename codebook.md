    Variable     | Description
-----------------|------------
    subject | Subject that performed the activity (range 1, 30)
    activityName | Activity identifier, one of WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING
    domain | Whether the feature is calculated from the time or frequency domain
    sensor | Sensor used to measure (Accelerometer or Gyroscope)
    component | Whether it is the body or gravitational component of the acceleration signal
    metric | Whether it is the mean or the std deviation
    isJerk | Whether it is jerk signal (TRUE or FALSE)
    isMagnitude | Whether it is a magnitude feature
    axis   | Axis of the measurement (X, Y, Z)
    count  | Count of the data points used to compute average
    average | Average of eachc variable for each subject and activity
