# Morphing World Logging API
Server IP: 45.32.231.66

port: 4596

## Log API
- HTTP/1.1 POST
  
  /api/mwlog
  
  body: { user, timestamp, data }

  return: { msg }

## Data Query API
- User number

  HTTP/1.1 GET
  
  /api/data/users
  
  return: user number

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