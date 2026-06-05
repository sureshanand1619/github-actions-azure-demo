const request = require('supertest');

let app;
let server;

beforeAll(() => {
  app = require('./index');
  server = app.listen(0);
});

afterAll((done) => {
  server.close(done);
});

describe('App Tests', () => {
  test('GET / returns app info', async () => {
    const res = await request(server).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('message');
    expect(res.body).toHaveProperty('environment');
  });

  test('GET /health returns healthy', async () => {
    const res = await request(server).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('healthy');
  });
});
