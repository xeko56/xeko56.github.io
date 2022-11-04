const express = require('express');
const mariadb = require("mariadb/callback");
require('dotenv').config()

let app = express();
const path = require('path');
app.use(express.urlencoded({ extended: true }));

let conn = mariadb.createConnection({
    host: process.env.DB_HOST,
    database: process.env.DB_DB,
    user: process.env.DB_USER,
    password: process.env.DB_PW
});

conn.connect(function(err) {
    if (err) throw err;

    app.listen(3000, function() {
        console.log('Listening on port 3000');
    });
});

app.get('/', function(req, res) {
    res.set('Content-Type', 'text/html');
    res.sendFile(path.join(__dirname + '/index.html'));
});
app.get('/mastermind.js', function(req, res) {
    res.sendFile(path.join(__dirname + '/mastermind.js'));
});

app.post('/save-score', function(req, res, next) {
    var playerName = req.body.playerName;
    var score = req.body.score;

    conn.query('INSERT INTO Highscore (playerName, score) VALUES ("' + playerName + '","' + score + '" )', function(err, rows, fields) {
        if (err) {
            throw err;
        } else {
            res.json({
                msg: 'success',
            });
        }
    });
});


app.get('/highscoreboard', function(req, res) {
    let sql = 'SELECT * FROM Highscore WHERE score > 500 ORDER BY score DESC';
    conn.query(sql, function(err, rows, fields) {
        if (err) {
            throw err;
        } else {}
        res.set('Content-Type', 'text/html');
        //res.send('<!DOCTYPE html><html lang="de"><head><title>Text</title></head><body><p>Highscore Board</p><p>Found: </p><pre>' + JSON.stringify(rows) + '</pre></body></html>');
        res.render('highscoreboard.ejs', { data: rows });
    });
});

try {
    conn.query("select 1", [], function(err, rows) {
        if (err) { throw err; }
        console.log(rows);
    });
} catch (e) {
    console.log(e);
}
