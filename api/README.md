# Morphing World Logging API
Server IP: 45.32.231.66

port: 4596

## Log API
- HTTP/1.1 POST
  
  /api/mwlog
  
  body: { user, timestamp, data }

  return: { msg }

## Data Query API
- Get user number

  HTTP/1.1 GET
  
  /api/data/users
  
  return: user number

- Get games statistic

  HTTP/1.1 GET
  
  /api/data/games
  
  return:
  
  ```json
  [
    {
        "user": "17aa4072-90bb-426e-b586-e53e9a77e9d0",
        "start": 1582532191.517,
        "stage0": {
            "time": 70.5460000038147,   // Time used in this stage, unit is second
            "death": 0,
            "reset": 0
        },
        ...
    }
  ]
  ```

- Get Start data

  HTTP/1.1 GET

  /api/data/time/start
  
  return: 

  ```json
  [
      {
        "user": "f0a4351f-1ff5-43e2-84fe-5d6321cb150c",
        "timestamp": "1582171601.321",
        "times": "1",
        "type": "Start"
      },
      ...
  ]
  ```

- Get Exit data

  HTTP/1.1 GET

  /api/data/time/exit
  
  return: 

  ```json
  [
      {
          "user": "f0a4351f-1ff5-43e2-84fe-5d6321cb150c",
          "timestamp": "1582171610.826",
          "type": "EXIT",
          "lastStage": "01_00",
          "settings": {
              "sound":true,
              "music":true,
              "volume":100
            },
      },
      ...
  ]
  ```

- Get raw data

  HTTP/1.1 GET
  
  /api/data/raw/all
  
  return: raw data