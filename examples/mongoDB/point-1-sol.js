idRoma = ObjectId();
idPalermo=ObjectId();
idNapoli=ObjectId();

db.city.insertOne(
{
 _id:idRoma,
 name: 'Roma',
 region: 'Lazio'
}
);


db.city.insertOne(
{
 _id:idPalermo,
 name: 'Palermo',
 region: 'Sicilia'
}
);

db.city.insertOne(
{
 _id:idNapoli,
 name: 'Napoli',
 region: 'Campania'
}
);

idAnna=ObjectId();
idFilippo = ObjectId();
idOlga=ObjectId();
idLuigi=ObjectId();
idLuisa=ObjectId();

db.person.insertOne(
{
 _id:idLuisa,
 name: 'Luisa',
 age: 75,
 salary: 85,
 gender: 'F'
}
);

db.person.insertOne(
{
 _id:idLuigi,
 name: 'Luigi',
 age: 50,
 salary: 40,
 gender: 'M',
 resides_in : idNapoli,
 parents:[{parent:idLuisa,
			childOrd:2
			}]  
});

db.person.insertOne(
{
 _id:idAnna,
 name: 'Anna',
 age: 50,
 salary: 35,
 gender: 'F'
}
);


db.person.insertOne(
{
 _id:idFilippo,
 name: 'Filippo',
 age: 20,
 salary: 30,
 gender: 'M',
 resides_in : idRoma,
 parents: [{parent:idAnna,
              childOrd:2},
			 {parent:idLuigi,
              childOrd:1}]
}
);


db.person.insertOne(
{
 _id:idOlga,
 name: 'Olga',
 age: 30,
 salary: 42,
 gender: 'F',
 resides_in :idPalermo,
 parents: [{parent:idAnna,
             childOrd:1}]
}
);

