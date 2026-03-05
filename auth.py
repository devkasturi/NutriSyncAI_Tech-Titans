from fastapi import HTTPException, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from config import supabase_admin

security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Security(security)
) -> str:
    token = credentials.credentials

    try:
        user_response = supabase_admin.auth.get_user(token)
        user = user_response.user

        if user is None:
            raise HTTPException(status_code=401, detail="Invalid or expired token")

        return user.id

    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Authentication failed: {str(e)}")