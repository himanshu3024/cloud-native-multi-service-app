import { render, screen } from '@testing-library/react';
import App from './App';

test('renders app title', () => {
  render(<App />);
  const titleElement = screen.getByText(/Cloud-Native Multi-Service App/i);
  expect(titleElement).toBeInTheDocument();
});

test('renders tech stack section', () => {
  render(<App />);
  const techStackElement = screen.getByText(/Tech Stack/i);
  expect(techStackElement).toBeInTheDocument();
});

test('renders API button', () => {
  render(<App />);
  const buttonElement = screen.getByRole('button');
  expect(buttonElement).toBeInTheDocument();
}); 