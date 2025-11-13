# tests/test_aurawear_helper.py
import json
import subprocess
from pathlib import Path

import pytest

# Path to the helper (adjust if you moved it)
HELPER = Path(__file__).parent.parent / "aurawear_helper.py"


@pytest.fixture
def mock_subprocess_run(monkeypatch):
    """
    Replace subprocess.run with a stub that pretends the commands succeeded.
    """
    def fake_run(*args, **kwargs):
        # Return a dummy CompletedProcess with no output (the helper will later
        # write the files, but we don't need to actually create them for the test)
        return subprocess.CompletedProcess(args, 0, stdout=b"", stderr=b"")

    monkeypatch.setattr(subprocess, "run", fake_run)
    return fake_run


def test_helper_returns_expected_json(mock_subprocess_run, tmp_path):
    prompt = "test cyber‑silk kimono"
    # Run the helper via subprocess (exactly as the TS launcher would)
    result = subprocess.run(
        ["python3", str(HELPER), prompt],
        cwd=tmp_path,
        capture_output=True,
        text=True,
        check=True,
    )

    # The helper prints a JSON string to stdout
    data = json.loads(result.stdout)

    # Basic sanity checks
    assert data["prompt"] == prompt
    assert "timestamp" in data
    assert "image_path" in data
    assert "audio_path" in data
    assert "model_path" in data

    # The paths should be relative to the CWD (tmp_path)
    assert data["image_path"].startswith("outputs/")
    assert data["audio_path"].startswith("outputs/")
    assert data["model_path"].startswith("outputs/")
