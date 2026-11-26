#!/usr/bin/env bash
# ==============================================================================
# fde-streamlit: Autonomous Streamlit Deployment & Mesh Management CLI
# Dual-track orchestration: Host Infrastructure & Streamlit Community Cloud
# ==============================================================================
set -euo pipefail

REPO_DIR="/home/ubuntu/projects/az-streamlit-showcase"
VENV_PYTHON="/home/ubuntu/.venvs/streamlit-env/bin/python"
VENV_STREAMLIT="/home/ubuntu/.venvs/streamlit-env/bin/streamlit"
SERVICE_NAME="az-streamlit-demo.service"
GITHUB_REPO="Amz34/az-streamlit-showcase"
ENTRYPOINT="app.py"

function usage() {
    echo "⚡ fde-streamlit CLI — Forward Deployed Engineering Deployment Mesh"
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  status       Check status of local host service, ports, and git sync"
    echo "  start        Start local Streamlit systemd background service"
    echo "  stop         Stop local Streamlit systemd service"
    echo "  restart      Restart local Streamlit systemd service"
    echo "  logs         Tail logs from the local Streamlit service"
    echo "  test         Execute headless smoke test on application files"
    echo "  push [msg]   Commit and push changes to GitHub (triggers Community Cloud build)"
    echo "  deploy-link  Print the 1-click Streamlit Community Cloud deployment URL"
    echo "  help         Display this help message"
}

CMD="${1:-status}"

case "$CMD" in
    status)
        echo "=========================================================="
        echo "⚡ AZ STREAMLIT MESH STATUS"
        echo "=========================================================="
        echo "📂 Directory: $REPO_DIR"
        echo "📦 GitHub Target: https://github.com/$GITHUB_REPO"
        echo "☁️ Streamlit Cloud Deploy Link:"
        echo "   https://share.streamlit.io/deploy?repository=$GITHUB_REPO&branch=main&main_module=$ENTRYPOINT"
        echo "----------------------------------------------------------"
        echo "🖥️ Local Systemd Service:"
        systemctl --user status "$SERVICE_NAME" --no-pager 2>&1 || echo "Service not currently running."
        echo "----------------------------------------------------------"
        echo "🌐 Port 8501 Listening Check:"
        ss -tuln | grep ':8501 ' || echo "Port 8501 is currently idle."
        ;;

    start)
        echo "🚀 Starting $SERVICE_NAME..."
        systemctl --user start "$SERVICE_NAME"
        echo "✅ Started. Checking status:"
        systemctl --user status "$SERVICE_NAME" --no-pager
        ;;

    stop)
        echo "🛑 Stopping $SERVICE_NAME..."
        systemctl --user stop "$SERVICE_NAME"
        echo "✅ Stopped."
        ;;

    restart)
        echo "🔄 Restarting $SERVICE_NAME..."
        systemctl --user restart "$SERVICE_NAME"
        echo "✅ Restarted."
        ;;

    logs)
        journalctl --user -u "$SERVICE_NAME" -f
        ;;

    test)
        echo "🧪 Running headless pre-flight tests..."
        cd "$REPO_DIR"
        $VENV_PYTHON -m py_compile app.py
        $VENV_PYTHON -m py_compile streamlit_app.py
        $VENV_PYTHON -c "import streamlit, pandas, altair, plotly; print('✅ All dependencies imported successfully.')"
        echo "✅ Pre-flight validation passed."
        ;;

    push)
        COMMIT_MSG="${2:-Deploy update via fde-streamlit CLI}"
        echo "📦 Pushing changes to GitHub ($GITHUB_REPO)..."
        cd "$REPO_DIR"
        git add .
        git commit -m "$COMMIT_MSG" || echo "No changes to commit."
        git push origin main
        echo "✅ Pushed to GitHub. Streamlit Community Cloud webhook will auto-deploy."
        ;;

    deploy-link)
        echo "https://share.streamlit.io/deploy?repository=$GITHUB_REPO&branch=main&main_module=$ENTRYPOINT"
        ;;

    help|--help|-h)
        usage
        ;;

    *)
        echo "Unknown command: $CMD"
        usage
        exit 1
        ;;
esac
