import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Start seeding...');

  // Create lessons with phrases
  const lesson1 = await prisma.lesson.create({
    data: {
      title: 'Basic Greetings',
      description: 'Learn essential greeting phrases in English',
      difficulty: 'Beginner',
      phrases: {
        create: [
          { text: 'Hello, how are you?' },
          { text: 'Good morning!' },
          { text: 'Good afternoon!' },
          { text: 'Good evening!' },
          { text: 'Nice to meet you.' },
          { text: 'How do you do?' },
          { text: 'What\'s up?' },
          { text: 'How\'s it going?' },
        ],
      },
    },
  });

  const lesson2 = await prisma.lesson.create({
    data: {
      title: 'Introducing Yourself',
      description: 'Practice self-introduction phrases',
      difficulty: 'Beginner',
      phrases: {
        create: [
          { text: 'My name is John.' },
          { text: 'I am from Vietnam.' },
          { text: 'I am a student.' },
          { text: 'I work as a teacher.' },
          { text: 'I live in Hanoi.' },
          { text: 'I am 25 years old.' },
          { text: 'Nice to meet you all.' },
        ],
      },
    },
  });

  const lesson3 = await prisma.lesson.create({
    data: {
      title: 'At the Restaurant',
      description: 'Common phrases used when dining out',
      difficulty: 'Intermediate',
      phrases: {
        create: [
          { text: 'Can I see the menu, please?' },
          { text: 'I would like to order.' },
          { text: 'What do you recommend?' },
          { text: 'I\'ll have the chicken, please.' },
          { text: 'Could I get some water?' },
          { text: 'Can I have the bill, please?' },
          { text: 'The food was delicious.' },
          { text: 'Do you accept credit cards?' },
        ],
      },
    },
  });

  const lesson4 = await prisma.lesson.create({
    data: {
      title: 'Shopping Expressions',
      description: 'Useful phrases for shopping',
      difficulty: 'Intermediate',
      phrases: {
        create: [
          { text: 'How much does this cost?' },
          { text: 'Can I try this on?' },
          { text: 'Do you have this in a different size?' },
          { text: 'I\'m just looking, thank you.' },
          { text: 'I\'ll take this one.' },
          { text: 'Do you accept returns?' },
          { text: 'Can I get a discount?' },
          { text: 'Where is the fitting room?' },
        ],
      },
    },
  });

  const lesson5 = await prisma.lesson.create({
    data: {
      title: 'Business Meeting',
      description: 'Professional phrases for business meetings',
      difficulty: 'Advanced',
      phrases: {
        create: [
          { text: 'Let\'s get started with the meeting.' },
          { text: 'Could you please elaborate on that?' },
          { text: 'I would like to propose an alternative.' },
          { text: 'Let\'s move on to the next agenda item.' },
          { text: 'Do we have any questions or concerns?' },
          { text: 'I appreciate your input on this matter.' },
          { text: 'Let\'s schedule a follow-up meeting.' },
          { text: 'Thank you all for your time today.' },
        ],
      },
    },
  });

  const lesson6 = await prisma.lesson.create({
    data: {
      title: 'Travel & Directions',
      description: 'Essential phrases for travelers',
      difficulty: 'Intermediate',
      phrases: {
        create: [
          { text: 'Excuse me, where is the nearest subway station?' },
          { text: 'How do I get to the airport?' },
          { text: 'Is it far from here?' },
          { text: 'Can you show me on the map?' },
          { text: 'How long does it take to get there?' },
          { text: 'Which bus should I take?' },
          { text: 'Could you call a taxi for me?' },
          { text: 'I\'m lost. Can you help me?' },
        ],
      },
    },
  });

  console.log('Seeding completed successfully!');
  console.log(`Created ${6} lessons with phrases`);
}

main()
  .catch((e) => {
    console.error('Error during seeding:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
