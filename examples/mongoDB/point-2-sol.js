// ============================================================================
// Point 2 // solutions
// ============================================================================

// 1) Find the people who earn more than 40 and return for each one a document with only the person name (solve with find(..));

db.person.find({ salary: { $gt: 40 } }, { name: 1,_id:0})


// 2) Find the men who earn more than 30 and return for each one a document with only the name (solve with find(..)); 

db.person.find( {$and :[{ salary: { $gt: 30 } },{ gender: 'M' }]}, { name: 1,_id:0})

// 3) Find people who are someone's second child and for each such person return a document with only the person name (solve with find(..), by using the $elemMatch operator);

db.person.find( {parents:{ $elemMatch: {childOrd:2}}}, { name: 1,_id:0})

// 4) For each person, return a document with the name of the person and the region in which she/he resides;

db.person.aggregate([
{$lookup:
		  { from:"city",
		    localField:"resides_in",
            foreignField:"_id",
            as:"city_details" }},
 {$unwind:'$city_details'},
 {$project: {_id:0,"person_name":"$name","residence_region": "$city_details.region"}}
 ])


// 5) Find the number of children per person by returning a document with the name of the person and the number of children;

db.person.aggregate([
  {$lookup:
		  { from:"person",
		    localField:"parents.parent",
            foreignField:"_id",
            as:"parent_details" }},
   {$unwind:'$parent_details'},
   {$project: {_id:0,"child_name":"$name","parent_name": "$parent_details.name"}},
   { $group: { _id: "$parent_name", count: {$sum: 1 }}}
])

// 6) Find the parents of people earning more than 30 and return for each such parent a document with only her/his name;

db.person.aggregate([
 {$match : {salary : {$gt:30}}}, 
 {$project: {_id:0,parents:1}}, 
 {$unwind:'$parents'},
 {$lookup:
		  { from:"person",
		    localField:"parents.parent",
            foreignField:"_id",
            as:"parent_details" }},
  {$unwind:'$parent_details'},
  {$project: {_id:0,"parent_name": "$parent_details.name"}}
])