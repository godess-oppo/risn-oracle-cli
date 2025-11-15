from rich.console import Console
from rich.table import Table
from rich.layout import Layout
from rich.panel import Panel
from rich.align import Align
from rich.live import Live
import time

class Dashboard:
    def __init__(self):
        self.console = Console()
    
    def show(self):
        layout = Layout()
        layout.split_column(
            Layout(name="header", size=3),
            Layout(name="main"),
            Layout(name="footer", size=3)
        )
        layout["main"].split_row(
            Layout(name="left"),
            Layout(name="right")
        )
        
        layout["header"].update(
            Panel("🎨 FashionForge CLI v0.1.0 - AI Fashion POD OS", style="bold magenta")
        )
        
        left_table = Table(title="Recent Designs", show_lines=True)
        left_table.add_column("ID", style="cyan")
        left_table.add_column("Status", style="green")
        left_table.add_column("Sales", style="yellow")
        left_table.add_row("ff-7h3k9m", "✅ Live", "$1,247")
        left_table.add_row("ff-8j4l2n", "🔄 Draft", "$0")
        
        layout["left"].update(left_table)
        
        right_panel = Panel(
            "[bold]Quick Commands:[/]\n"
            "• fashionforge generate -p 'prompt' -g hoodie\n"
            "• fashionforge publish -d ff-001 -p printify\n"
            "• fashionforge trends -c streetwear\n"
            "• fashionforge price -d ff-001 --strategy dynamic",
            title="Get Started"
        )
        layout["right"].update(right_panel)
        
        layout["footer"].update(
            Panel("💡 Tip: Use 'fashionforge voice' for hands-free operation", style="dim")
        )
        
        self.console.print(layout)
