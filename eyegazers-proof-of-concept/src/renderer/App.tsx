import { Index } from "./components/Index";
import "../App.css";

export default function App() {
  return (
    <div
      className="container"
      style={{
        backgroundColor: "#1a1a1a",
        color: "#e0e0e0",
        minHeight: "100vh",
        padding: "20px",
        fontFamily: "Arial, sans-serif",
        position: "fixed",
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        overflow: "hidden",
      }}
    >
      <h1 style={{ color: "#61dafb", marginBottom: "20px" }}>AI Autocomplete</h1>
      <Index />
    </div>
  );
}