export default function LoadingState({ text = 'Laen...' }: { text?: string }) {
  return <div className="loading">{text}</div>;
}
