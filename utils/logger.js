var winston = require('winston');
var config = require('../config');
winston.emitErrs = true;

var myLogTransports = [];
console.log(process.env.NODE_ENV);
if(process.env.NODE_ENV == 'production'){
    myLogTransports.push(new (winston.transports.File)({filename: config.logsFolder+'/rt-syndication-template.log', json: false, maxsize: 5242880, maxFiles: 5, colorize: false, handleExceptions: true}));
}
else{
    myLogTransports.push(new (winston.transports.Console)({ level: 'debug', handleExceptions: true, json:false, colorize: true}));
}

var logger = new (winston.Logger)({
  transports: myLogTransports,
});
/*
var logger = new winston.Logger({
    transports: [
        new winston.transports.File({
            level: 'info',
            filename: './logs/all-logs.log',
            handleExceptions: true,
            json: false,
            maxsize: 5242880, //5MB
            maxFiles: 5,
            colorize: false,
        }),
        new winston.transports.Console({
            level: 'debug',
            handleExceptions: true,
            json: false,
            colorize: true
        })
    ],
    exitOnError: true
});
*/
module.exports = logger;
module.exports.stream = {
    write: function(message, encoding){
        logger.info(message.slice(0,-1));
    }
};