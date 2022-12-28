const express = require('express')
const app = express()
const port = 3030
const MongoClient = require('mongodb').MongoClient
const config = require('./config');
const session = require('express-session');
const crypto = require('crypto');

var bodyParser = require('body-parser')
var validate = require('jsonschema').validate;
// console.log(validate(4, {"type": "number"}));
// console.log(v.validate(p, schema));
var crystalSchema = require("./crystalSchema")

app.set('view engine', 'ejs')

// parse application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({ extended: false }))

// parse application/json
app.use(bodyParser.json())

// create application/json parser
var jsonParser = bodyParser.json()

// create application/x-www-form-urlencoded parser
var urlencodedParser = bodyParser.urlencoded({ extended: false })

app.use(session({
  secret: 'secret',
  resave: true,
  saveUninitialized: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
// app.use(express.static(path.join(__dirname, 'static')));

function getRndInteger(min, max) {
  return Math.floor(Math.random() * (max - min + 1) ) + min;
}
function getRndGPSinM(center, distance) {
  var meters = getRndInteger(-distance,distance)
  return center + convMtoGPS(meters)
}
function convMtoGPS(m){
  return m / 111111 
}
function convGPStoM(gps){
  return gps * 111111
}


MongoClient.connect(config.db, (err, client) => {
  if (err) return console.error(err)
  console.log('Connected to Database')

  const db = client.db('cluster0')
  const testColl = db.collection('testColl')
  const userColl = db.collection('userColl')
  const crystalColl = db.collection('crystalColl')

  app.get('/', (req, res) => {
    // const cursor = db.collection('quotes').find()
    // console.log(cursor)
    
    res.send('Hello World!')
  })


  app.get('/createuser', (req, res) => {
    // const cursor = db.collection('quotes').find()
    // console.log(cursor)
    
    // res.send('Create a user:')
    res.render('index.ejs', {})
  })

  app.post('/newacct', urlencodedParser, function (req, res) {
    console.log("post before db",req.body)
    var user = {}

    if(req.body.password1 == req.body.password2){
      // setup my user
      user.email = req.body.email
      user.password = req.body.password1
      user.timeCreated = Date.now()
      user.name = req.body.name
      userColl.insertOne(user)
      .then(result => {
        // res.send('welcome, ' + req.body.username)
        req.session.loggedin = true;
        req.session.username = req.body.name;
        console.log("insertOne result:", result)
        res.redirect('/home');
        
      })
      .catch(error => console.error(error))
    }else{

    }
    
    // res.send('welcome, ' + req.body.username)
  })

  app.post('/auth', function(req, res) {
    // Capture the input fields
    let email = req.body.email;
    let password = req.body.password;
    // Ensure the input fields exists and are not empty
    if (email && password) {

      userColl.findOne({email:email, password:password})
      .then(result => {
        console.log("after get", result)
        // res.json(results)
        if(result){
          // console.log(doc); // print out what it sends back
          req.session.loggedin = true;
          req.session.username = result.name;
          // Redirect to home page
          res.redirect('/home');
        }else if(!result){
          console.log("Not in docs");
          res.send('Incorrect Username and/or Password!');
        }
      })
      .catch(error => console.error(error))
    } else {
      res.send('Please enter Username and Password!');
      res.end();
    }
  });

  // http://localhost:3000/home
  app.get('/home', function(req, res) {
    // If the user is loggedin
    if (req.session.loggedin) {
      // Output username
      res.send('Welcome back, ' + req.session.username + '!');
    } else {
      // Not logged in
      res.send('Please <a href="/login">login</a> to view this page!');
    }
    res.end();
  });


  // http://localhost:3000/home
  app.get('/login', function(req, res) {
    res.render('login.ejs', {})
  });

  app.get('/getToken', (req, res) => {
    // const cursor = db.collection('quotes').find()
    // console.log(cursor)
    var token = crypto.randomBytes(64).toString('hex');
    console.log("made token:", token) 
    res.send(token)
    // res.render('index.ejs', {})
  })

  app.post('/getCrystals', function(req, res) {
    // Capture the input fields
    let mylat = req.body.mylat;
    let mylong = req.body.mylong;
    // Ensure the input fields exists and are not empty
    if (mylat && mylong) {

      crystalColl.find({ $and: [  
            { $or: [ { lat: {$gt: mylat - 1} }, { lat: {$lt: mylat + 1} } ] }, 
            { $or: [ { long: {$gt: mylong -1} }, { long: {$lt: mylong + 1} } ] } 
          ]} ).toArray()
          // ]} ).limit(2).toArray()
      .then(results => {
        // console.log("after get", results)
        // res.json(results)
        if(results){
          console.log("getCrystals results: ", JSON.stringify(results) ); // print out what it sends back
          // req.session.loggedin = true;
          // req.session.username = results.name;
          // // Redirect to home page
          // res.redirect('/home');
          res.send(JSON.stringify(results))
        }else if(!results){
          console.log("Not in docs");
          // res.send('Incorrect Username and/or Password!');
        }
      })
      .catch(error => console.error(error))
    } else {
      res.send('Please enter Username and Password!');
      res.end();
    }
  });

  app.get('/inventSomeCrystals', (req, res) => {
    // res.send('phone app made a get request!')
    // var crystalElem = {}
    // crystalElem.lat = getRndGPSinM(30.6389954, 1000)
    // crystalElem.long = getRndGPSinM(-97.6856937, 1000)
    // crystalElem.timeCreated = Date.now()

    // // create an array of documents to insert
    // const docs = [
    //   { name: "cake", healthy: false },
    //   { name: "lettuce", healthy: true },
    //   { name: "donut", healthy: false }
    // ];
    // // this option prevents additional documents from being inserted if one fails
    // const options = { ordered: true };
    // const result = await foods.insertMany(docs, options);
    // console.log(`${result.insertedCount} documents were inserted`);

    bulkUpdateOps = [];  

    for (var i = 0; i < 10; i++) {
      var crystalElem = {}
      crystalElem.lat = getRndGPSinM(30.6389954, 1000)
      crystalElem.long = getRndGPSinM(-97.6856937, 1000)
      crystalElem.type = getRndInteger(1,2)
      crystalElem.timeCreated = Date.now()

      bulkUpdateOps.push({ "insertOne": { "document": crystalElem } });

    }

    // entries.forEach(function(doc) {
    //     bulkUpdateOps.push({ "insertOne": { "document": doc } });

    //     // if (bulkUpdateOps.length === 1000) {
    //     //     collection.bulkWrite(bulkUpdateOps).then(function(r) {
    //     //         // do something with result
    //     //     });
    //     //     bulkUpdateOps = [];
    //     // }
    // })

    if (bulkUpdateOps.length > 0) {
      crystalColl.bulkWrite(bulkUpdateOps).then(function(r) {
          // do something with result
        console.log("inventSomeCrystals: ",r);
        res.send('Invented some crystals!');
      });
    }

    // crystalColl.insertOne(crystalElem)
    //   .then(result => {
    //     // res.send('welcome, ' + req.body.username)
    //     res.json(req.body)
    //   })
    //   .catch(error => console.error(error))
  })






  app.get('/testget', (req, res) => {
    // res.send('phone app made a get request!')
    testColl.find().toArray()
      .then(results => {
        console.log("after get", results)
        // res.json(results)
        res.json(results)
      })
      .catch(error => console.error(error))
  })


  app.post('/testpost', urlencodedParser, function (req, res) {
    console.log("post before db",req.body)
    testColl.insertOne(req.body)
      .then(result => {
        // res.send('welcome, ' + req.body.username)
        res.json(req.body)
      })
      .catch(error => console.error(error))
    // res.send('welcome, ' + req.body.username)
  })

})


// app.get('/', (req, res) => {
//   res.send('Hello World!')
// })


// app.get('/testget', (req, res) => {
//   res.send('phone app made a get request!')
// })

// // app.post('/testpost', (req, res) => {
// //   console.log(req.body)
// //   res.send('POST request to the homepage')
// // })

// app.post('/testpost', urlencodedParser, function (req, res) {
//   console.log(req.body)
//   res.send('welcome, ' + req.body.username)
// })

// app.route('/book')
//   .get((req, res) => {
//     res.send('Get a random book')
//   })
//   .post((req, res) => {
//     res.send('Add a book')
//   })
//   .put((req, res) => {
//     res.send('Update the book')
//   })




app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})