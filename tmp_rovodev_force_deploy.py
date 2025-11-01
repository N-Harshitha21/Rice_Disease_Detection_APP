#!/usr/bin/env python3
"""
Force immediate deployment with git commit
"""
import subprocess
import time

def force_git_deployment():
    """Force a git commit to trigger Render.com deployment"""
    try:
        print("🔄 FORCING RENDER.COM DEPLOYMENT")
        print("=" * 40)
        
        # Check git status
        result = subprocess.run(['git', 'status', '--porcelain'], 
                              capture_output=True, text=True)
        
        if result.stdout.strip():
            print("📝 Changes detected, committing...")
            
            # Add all changes
            subprocess.run(['git', 'add', '.'], check=True)
            
            # Commit with deployment message
            commit_msg = "Emergency fix: Laptop-free cloud API deployment"
            subprocess.run(['git', 'commit', '-m', commit_msg], check=True)
            
            print("✅ Changes committed")
            
            # Push to trigger deployment
            subprocess.run(['git', 'push'], check=True)
            print("🚀 Pushed to repository - deployment triggered!")
            
            return True
        else:
            print("📝 No uncommitted changes found")
            
            # Create a small change to trigger deployment
            with open('deployment_trigger.txt', 'w') as f:
                f.write(f"Deployment triggered at {time.time()}")
            
            subprocess.run(['git', 'add', 'deployment_trigger.txt'], check=True)
            subprocess.run(['git', 'commit', '-m', 'Trigger emergency deployment'], check=True)
            subprocess.run(['git', 'push'], check=True)
            
            print("🚀 Deployment trigger pushed!")
            return True
            
    except subprocess.CalledProcessError as e:
        print(f"❌ Git operation failed: {e}")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    print("🚨 FORCING CLOUD DEPLOYMENT")
    print("=" * 30)
    
    print("💡 The emergency API is ready but Render.com needs a trigger")
    print("🔄 Forcing git deployment...")
    
    if force_git_deployment():
        print("\n✅ DEPLOYMENT TRIGGERED!")
        print("⏰ Render.com will deploy in 2-5 minutes")
        print("🔍 Monitor deployment at: https://dashboard.render.com")
        
        print("\n📊 What happens next:")
        print("1. Render.com builds with emergency API")
        print("2. Emergency model loading starts")
        print("3. Your app works WITHOUT laptop!")
        
        print("\n⏳ Test again in 5 minutes with:")
        print("python tmp_rovodev_final_test.py")
        
    else:
        print("\n❌ Could not trigger deployment")
        print("💡 Manual options:")
        print("1. Go to Render.com dashboard")
        print("2. Click 'Manual Deploy' > 'Deploy latest commit'")
        print("3. Wait for deployment to complete")

if __name__ == "__main__":
    main()