import { Link } from 'react-router-dom';

export default function Header() {
  return (
    <header className="app-header">
      <div>
        <h1>TalTech Marketplace</h1>
        <p>Müüja töökoha prototüüp — Roger Purtsak</p>
      </div>
      <nav>
        <Link to="/">Minu kuulutused</Link> | <Link to="/create">Lisa kuulutus</Link>
      </nav>
    </header>
  );
}
