const express = require('express')
const app = express()
const port = 3030
const MongoClient = require('mongodb').MongoClient
const mongoose = require('mongoose');
const config = require('./config');
const session = require('express-session');
const crypto = require('crypto');

var ObjectId = require('mongodb').ObjectID;
var bodyParser = require('body-parser')
var validate = require('jsonschema').validate;
// console.log(validate(4, {"type": "number"}));
// console.log(v.validate(p, schema));
var crystalSchema = require("./crystalSchema")
var crystalArray = require("./crystalArray")
const Crystal = mongoose.model('Crystal', crystalSchema);

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
const oneHour = 60 * 60 * 1001 /* ms */

function getRndInteger(min, max) {
  return Math.floor(Math.random() * (max - min + 1) ) + min;
}
function getRndGPSinM(center, distance) {
  var meters = getRndInteger(-distance,distance)
  return center + convMtoGPS(meters)
}
function convMtoGPS(m){
  return parseFloat(m / 111111)
}
function convGPStoM(gps){
  return parseFloat(gps * 111111)
}
function getRndGPSPairFromCenter(lat, long, radius){
  var gps = {}
  gps.lat = getRndGPSinM(lat, radius) // my lat, long
  gps.long = getRndGPSinM(long, radius)
  return gps
}
function getRndGPSNearMe(radius=1000){
  return getRndGPSPairFromCenter(30.6389954, -97.6856937, radius)
}
  //31.841401, -98.884759 // 321,800 // center-is of texas to closest borders (mexico and gainesville)
function getRndGPSinTexas(lat=31.841401, long=-98.884759,radius=353800){
  return getRndGPSPairFromCenter(lat, long, radius)
}

function getRndGPSRndMethod(){
  var method = getRndInteger(1,10)
  if(method = 1){

  }else{

  }
}

function generateCrystal(me=false,token=null){
  var crystalElem, gps = {}
  if(me){
    gps = getRndGPSNearMe()
  }else{
    gps = getRndGPSinTexas()
  }
  var type = getRndInteger(1,crystalArray.arr.length)
  crystalElem = crystalArray.arr[type-1]
  // console.log("crystalElem:", crystalElem)
  crystalElem.lat = gps.lat
  crystalElem.long = gps.long
  crystalElem.condition = "meh"
  crystalElem.grading = getRndInteger(1,40) + getRndInteger(0,60)
  crystalElem.token = token

  return new Crystal(crystalElem);
}

MongoClient.connect(config.db, (err, client) => {
  if (err) return console.error(err)
  console.log('Connected to Database')

  const db = client.db('cluster0')
  const testColl = db.collection('testColl')
  const userColl = db.collection('userColl')
  const crystalColl = db.collection('crystalColl')
  const ownedCrystalColl = db.collection('ownedCrystalColl')

  function refreshCrystals(res){
    var dtNow = Date.now()
    // var tooOld = dtNow 
    var tooOld = dtNow - 12 * oneHour
    crystalColl.deleteMany( { timeCreated: { $lt: tooOld } } )
    .then(result => {
      console.log("refreshCrystals result:", result, dtNow, tooOld)
      // res.send(JSON.stringify(result) + 'Deleted some crystals!')
      if (result.deletedCount) {inventCountCrystals(res, result.deletedCount, false, result)}
    })
    .catch(error => console.error(error))

  }

  function inventCountCrystals(res, count=10, me=false, didDelete=""){
    bulkUpdateOps = [];  
    for (var i = 0; i < count; i++) {
      
      const crystal = generateCrystal(me)

      bulkUpdateOps.push({ "insertOne": { "document": crystal } });
    }

    if (bulkUpdateOps.length > 0) {
      crystalColl.bulkWrite(bulkUpdateOps).then(function(r) {
          // do something with result
        console.log("inventCountCrystals(): ",r);
        res.send('Invented count crystals, '+count+"|"+didDelete);
      });
    }
  }

  app.get('/', (req, res) => {
    // const cursor = db.collection('quotes').find()
    // console.log(cursor)
    
    // res.send('Hello World!')
    res.render('index.ejs', {})

  })


  app.get('/createuser', (req, res) => {
    // const cursor = db.collection('quotes').find()
    // console.log(cursor)
    
    // res.send('Create a user:')
    res.render('createuser.ejs', {})
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
    var range = 1000 // meters
    var gpsRange = parseFloat(convMtoGPS(range))
    let mylat = parseFloat(req.body.mylat);
    let mylong = parseFloat(req.body.mylong);
    // Ensure the input fields exists and are not empty
    if (mylat && mylong) {
      // console.log("query: ", mylat, mylong, gpsRange)
      // var testVar = mylat+gpsRange
      // console.log("query2: ", testVar)
      // { price: { $ne: 1.99, $exists: true } }
      crystalColl.find({ $and: [  
            { lat: {$gt: mylat - gpsRange , $lt: mylat + gpsRange} }, 
            { long: {$gt: mylong - gpsRange , $lt: mylong + gpsRange} } 
          ]} ).toArray()
      // crystalColl.find({ $and: [  
      //       { lat: {$gt: 29 , $lt: 31} }, 
      //       { long: {$gt: -98 , $lt: -96} } 
      //     ]} ).toArray()
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

  app.get('/forceCrystalRefresh', (req, res) => {
    refreshCrystals(res)
  });


  app.get('/inventCountCrystals', (req, res) => {
    // let email = req.body.email;
    var count = 10
    var me = false
    console.log("query: ",req.query)
    if(req.query){
      if(req.query.count){
        count = req.query.count
      }
      if(req.query.me){
        me = req.query.me
      }
    }
    inventCountCrystals(res, count, me)
  })


  app.get('/sendDelete', (req, res) => {
    console.log("sendDelete query: ",req.query)
    if(req.query && req.query.id){
      var id = ObjectId(req.query.id)
      crystalColl.find({ "_id": id }).toArray()
      .then(result => {
        // will do transfer to other db here
        console.log("sendDelete find result: ",result);
        if(req.query.token){
          result[0].token = req.query.token
          ownedCrystalColl.insertOne(result[0])
        }
        
        crystalColl.deleteOne({ "_id": id  })
          .then(result => {
          console.log("sendDelete result:", result)
          if (result.deletedCount) {
            res.send(req.query.id)
          }
        })
        .catch(error => console.error(error))
      })
      .catch(error => console.error(error))
    }
    // // let email = req.body.email;
    // // var count = 10
    // console.log("sendDelete query: ",req.query)
    // if(req.query && req.query.id){
    //   // count = req.query.count
    //   crystalColl.deleteOne( { "_id" : ObjectId(req.query.id) } )
    //   // crystalColl.deleteOne( { "_id" : req.query.id} )
    //   .then(result => {
    //     console.log("sendDelete result:", result)
    //     // res.send(JSON.stringify(result) + 'Deleted some crystals!')
    //     if (result.deletedCount) {
    //       res.send(req.query.id)
    //       //db.employees.remove({ "_id": 3 })
    //     }
    //   })
    //   .catch(error => console.error(error))
    // }
    // // inventCountCrystals(res, count)
    // // send.res
  })



  app.get('/sendWholesale', (req, res) => {
    console.log("sendWholesale query: ",req.query)
    if(req.query && req.query.id){
      var id = ObjectId(req.query.id)
      ownedCrystalColl.find({ "_id": id }).toArray()
      .then(result => {
        // will do transfer to other db here
        console.log("sendWholesale find result: ",result);
        if(result[0].token){
          // result[0].token = req.query.token
          // ownedCrystalColl.insertOne(result[0])
          // UPDATE user stats with money from sale
        }
        
        ownedCrystalColl.deleteOne({ "_id": id  })
          .then(result => {
          console.log("sendDelete result:", result)
          if (result.deletedCount) {
            res.send(req.query.id)
          }
        })
        .catch(error => console.error(error))
      })
      .catch(error => console.error(error))
    }
  })

  app.get('/giveTestCrystals', (req, res) => {
    // console.log("giveTestCrystals query: ",req.query)
    var count = 1
    // console.log("query: ",req.query)
    if(req.query){
      if(req.query.count){
        count = req.query.count
      }
    }

    var token = "dc3a55f751e8b15f4d14de90b2036135c75cb285ffdb48469d5ac996f8650258983cb36acb225dd42ac595a2be81fb62e9e5948304304a7f8628c8e7784b48e4"

    // var crystal = generateCrystal(false,token)
    // console.log("giveTestCrystals: ",crystal)
    // ownedCrystalColl.insertOne(crystal)
  
    bulkUpdateOps = [];  
    for (var i = 0; i < count; i++) {
      
      const crystal = generateCrystal(false,token)

      bulkUpdateOps.push({ "insertOne": { "document": crystal } });
    }

    if (bulkUpdateOps.length > 0) {
      ownedCrystalColl.bulkWrite(bulkUpdateOps).then(function(r) {
          // do something with result
        console.log("giveTestCrystals(): ",r);
        res.send('giveTestCrystals count crystals, '+count);
      });
    }
  })

  app.post('/postMyCrystals', function(req, res) {
    // Capture the input fields

    let token = req.body.token;
    // Ensure the input fields exists and are not empty
    if (token ) {
      // console.log("query: ", mylat, mylong, gpsRange)
      // var testVar = mylat+gpsRange
      // console.log("query2: ", testVar)
      // { price: { $ne: 1.99, $exists: true } }
      ownedCrystalColl.find({ "token": token  }).toArray()
      .then(results => {
        // console.log("after get", results)

        if(results){
          console.log("postMyCrystals results: ", JSON.stringify(results) ); // print out what it sends back

          res.send(JSON.stringify(results))
        }else if(!results){
          console.log("Not in docs");
        }
      })
      .catch(error => console.error(error))
    } else {
      res.send('Failure to parse token!');
      res.end();
    }
  });





















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