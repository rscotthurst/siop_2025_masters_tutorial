# Run with streamlit run chat_bedrock_st.py

import dotenv
import streamlit as st

dotenv.load_dotenv()

st.title('Chat Bot Demo')
st.subheader("Powered by Amazon Bedrock with Titan Text G1 - Express",
             divider="rainbow")
