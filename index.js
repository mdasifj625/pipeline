import express from 'express';
const app = express();

app.get('/', (req, res) => {
	res.send({
		status: 'success',
		message: 'Welcome to the ec2 machine',
	});
});
app.get('/time', (req, res) => {
	res.send({
		status: 'success',
		message: new Date().toLocaleString(),
	});
});

app.listen(3300, () => {
	console.log('server is up 🤫');
});
