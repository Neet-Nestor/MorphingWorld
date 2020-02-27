var http = require('http');

main();

//num_users();
//starts();


function main() {
    http.get('http://45.32.231.66:4596/api/data/games', (resp) => {
        let data = '';
        var data_json = '';
    
        resp.on('data', (chunk) => {
            data += chunk;
        });
        resp.on('end', () => {
            data_json = JSON.parse(data);
            for (var i = 0; i < data_json.length; i++) {
                var play = data_json[i]
                console.log('Play ' + i + ': ');
                console.log('\tUser: ' + play['user']);
                var start_time = new Date(play['start'] * 1000);
                console.log('\tStarted: ' + start_time);
                if (play['exit'] != null) {
                    var exit_time = new Date(play['exit'] * 1000);
                    console.log('\tPlay duration : ' + Math.round((exit_time - start_time) / 1000));
                }
                
                
                for (var j = 0; j < 12; j++) {
                    var stage_name = 'stage' + j;
                    var stage = play[stage_name];
                    if (stage != null) {
                        console.log('\tStage ' + j);
                        console.log('\t\tTime: ' + Math.round(stage['time']));
                        console.log('\t\tDeath: ' + stage['death']);
                    }
                }
                
                
                //console.log('\tPlayed: ' + play.times);
            }

        });
    
    }).on("error", (err) => {
        console.log("Error: " + err.message);
    });
}

function starts() {
    http.get('http://45.32.231.66:4596/api/data/time/start', (resp) => {
        let data = '';
        var data_json = '';
    
        // A chunk of data has been recieved.
        resp.on('data', (chunk) => {
            data += chunk;
        });
        // The whole response has been received. 
        resp.on('end', () => {
            data_json = JSON.parse(data);
            for (var i = 0; i < data_json.length; i++) {
                var play = data_json[i]
                console.log("Start " + i + ": ");
                var d = new Date(play.timestamp * 1000);
                console.log('\t' + d);
                console.log('\tUser: ' + play.user);
                console.log('\tPlayed: ' + play.times);
            }

        });
    
    }).on("error", (err) => {
        console.log("Error: " + err.message);
    });
}




function num_users() {
    http.get('http://45.32.231.66:4596/api/data/users', (resp) => {
        let data = '';
    
        // A chunk of data has been recieved.
        resp.on('data', (chunk) => {
            data += chunk;
        });
        // The whole response has been received. 
        resp.on('end', () => {
            console.log(data);
        });
    
    }).on("error", (err) => {
        console.log("Error: " + err.message);
    });
}
