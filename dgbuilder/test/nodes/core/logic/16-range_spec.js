/**
 * Copyright 2014 IBM Corp.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

var should = require("should");

var rangeNode = require("../../../../nodes/core/logic/16-range.js");
var helper = require("../../helper.js");

describe('RangeNode', function() {
    
    beforeEach(function(done) {
        helper.startServer(done);
    });
    
    afterEach(function(done) {
        helper.unload();
        helper.stopServer(done);
    });

    it('should be loaded', function(done) {
        var flow = [{"id":"rangeNode1","type":"range","minin":"0","maxin":"99","minout":"100","maxout":"199","action":"range","round":true,"name":"rangeNode","wires":[[]]}];
        helper.load(rangeNode, flow, function() {
            var rangeNode1 = helper.getNode("rangeNode1");
            rangeNode1.should.have.property('name', 'rangeNode');
            done();
        });
    });
    
    /**
     * Run a generic range test
     * @param action - scale/clamp (range limit)/roll (modulo): what action to choose
     * @param minin - map from minimum value
     * @param maxin - map from maximum value
     * @param minout - map to minimum value
     * @param maxout - map to maximum value 
     * @param round - whether to round the result to the nearest integer
     * @param aPayload - what payload to send to the range node
     * @param expectedResult - what result we're expecting
     * @param done - the callback to call when test done
     */
    function genericRangeTest(action, minin, maxin, minout, maxout, round, aPayload, expectedResult, done) {
        var flow = [{"id":"rangeNode1","type":"range","minin":minin,"maxin":maxin,"minout":minout,"maxout":maxout,"action":action,"round":round,"name":"rangeNode","wires":[["helperNode1"]]},
                    {id:"helperNode1", type:"helper", wires:[]}];
        helper.load(rangeNode, flow, function() {
            var rangeNode1 = helper.getNode("rangeNode1");
            var helperNode1 = helper.getNode("helperNode1");
            helperNode1.on("input", function(msg) {
                try {
                    msg.payload.should.equal(expectedResult);
                    done();
                } catch(err) {
                    done(err);
                }
            });
            rangeNode1.receive({payload:aPayload});
        });
    }
    
    it('ranges numbers up tenfold', function(done) {
        genericRangeTest("scale", 0, 100, 0, 1000, false, 50, 500, done);
    });
    
    it('ranges numbers down such as centimetres to metres', function(done) {
        genericRangeTest("scale", 0, 100, 0, 1, false, 55, 0.55, done);
    });
    
    it('wraps numbers down say for degree/rotation reading 1/2', function(done) {
        genericRangeTest("roll", 0, 10, 0, 360, true, 15, 180, done); // 1/2 around wrap => "one and a half turns"
    });
    
    it('wraps numbers around say for degree/rotation reading 1/3', function(done) {
        genericRangeTest("roll", 0, 10, 0, 360, true, 13.3333, 120, done); // 1/3 around wrap => "one and a third turns"
    });
    
    it('wraps numbers around say for degree/rotation reading 1/4', function(done) {
        genericRangeTest("roll", 0, 10, 0, 360, true, 12.5, 90, done); // 1/4 around wrap => "one and a quarter turns"
    });
    
    it('wraps numbers around say for degree/rotation reading 1/4', function(done) {
        genericRangeTest("roll", 0, 10, 0, 360, true, 12.5, 90, done); // 1/4 around wrap => "one and a quarter turns"
    });
    
    it('wraps numbers down say for degree/rotation reading 1/4', function(done) {
        genericRangeTest("roll", 0, 10, 0, 360, true, -12.5, 270, done); // 1/4 backwards wrap => "one and a quarter turns backwards"
    });
    
    it('clamps numbers within a range - over max', function(done) {
        genericRangeTest("clamp", 0, 10, 0, 1000, false, 111, 1000, done);
    });
    
    it('clamps numbers within a range - below min', function(done) {
        genericRangeTest("clamp", 0, 10, 0, 1000, false, -1, 0, done);
    });
    
    it('reports if input is not a number', function(done) {
        var flow = [{"id":"rangeNode1","type":"range","minin":0,"maxin":0,"minout":0,"maxout":0,"action":"scale","round":true,"name":"rangeNode","wires":[["helperNode1"]]},
                    {id:"helperNode1", type:"helper", wires:[]}];
        helper.load(rangeNode, flow, function() {
            var rangeNode1 = helper.getNode("rangeNode1");
            var helperNode1 = helper.getNode("helperNode1");
            
            var sinon = require('sinon');
            sinon.stub(rangeNode1, 'log', function(log) {
                if(log.indexOf("Not a number") > -1) {
                    done();
                } else {
                    try {
                        should.fail(null, null, "Non-number inputs should be reported!");   
                    } catch (err) {
                        done(err);
                    }
                }
            });
            
            rangeNode1.receive({payload:"NOT A NUMBER"});
        });
    });
});
