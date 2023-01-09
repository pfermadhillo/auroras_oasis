// import mongoose from 'mongoose';
const mongoose = require('mongoose');

const { Schema } = mongoose;

const userSchema = new Schema({
  name:  String, // String is shorthand for {type: String}
  token: String,
  money: Number,
  email: {
    type: String,
    trim: true,
    lowercase: true,
    unique: true,
    validate: {
        validator: function(v) {
            return /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(v);
        },
        message: "Please enter a valid email"
    },
    required: [true, "Email required"]
  }
  // password
  timeCreated: { type: Number, default: Date.now }
});


module.exports = userSchema;
