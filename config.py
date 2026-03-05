import os
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()  # Reads .env file and loads values into environment

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_ANON_KEY = os.getenv("SUPABASE_ANON_KEY")
SUPABASE_SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

# Service role client — full access, used for backend operations
# like writing meal plans, reading all user data for ML
supabase_admin: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

# Anon client — used when you want to respect RLS policies
supabase_public: Client = create_client(SUPABASE_URL, SUPABASE_ANON_KEY)