c.InteractiveShellApp.extensions = ["autoreload"]
c.InteractiveShellApp.exec_lines = ["%autoreload 2"]

c.InteractiveShellApp.extensions = ["rich", "pyflyby"]

c.InteractiveShellApp.exec_lines = [
    "from rich import inspect",
    "from rich import traceback",
    "traceback.install(show_locals=False, extra_lines=1, max_frames=3)",
    "from rich import pretty",
    "pretty.install()",
]
