import express from 'express';
const app = express();

app.get('/', (req, res) => {
	res.send({
		status: 'success',
		message: 'Welcome to the ec2 machine',
	});
});

app.listen(80, () => {
	console.log('server is up 🤫');
});
