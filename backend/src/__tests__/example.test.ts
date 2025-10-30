describe('Example Test Suite', () => {
  it('should return true', () => {
    expect(true).toBe(true);
  });

  it('should perform basic arithmetic', () => {
    expect(2 + 2).toBe(4);
    expect(10 - 5).toBe(5);
    expect(3 * 4).toBe(12);
    expect(8 / 2).toBe(4);
  });

  it('should handle string operations', () => {
    const greeting = 'Hello, World!';
    expect(greeting).toContain('World');
    expect(greeting.length).toBe(13);
    expect(greeting.toLowerCase()).toBe('hello, world!');
  });

  it('should work with arrays', () => {
    const numbers = [1, 2, 3, 4, 5];
    expect(numbers).toHaveLength(5);
    expect(numbers).toContain(3);
    expect(numbers[0]).toBe(1);
  });

  it('should work with objects', () => {
    const user = {
      name: 'John Doe',
      email: 'john@example.com',
      age: 30,
    };
    expect(user).toHaveProperty('name');
    expect(user.email).toBe('john@example.com');
    expect(user.age).toBeGreaterThan(18);
  });
});
