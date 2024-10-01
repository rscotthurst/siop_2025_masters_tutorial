# Run with streamlit run chat_bedrock_st.py

import time
import json
import dotenv
import boto3
import streamlit as st

dotenv.load_dotenv()

st.title('Chat Bot Demo')
st.subheader("Powered by Amazon Bedrock with Titan Text G1 - Express",
             divider="rainbow")

# # Setup bedrock
# session = boto3.Session()
# bedrock_runtime = session.client(service_name="bedrock-runtime")
#
#
# @st.cache_resource
# def send_prompt(prompt, model_id, temperature=0.0, max_token_count=512):
#     body = json.dumps(
#         {
#             "inputText": prompt,
#             "textGenerationConfig": {
#                 "temperature": temperature,
#                 "maxTokenCount": max_token_count,
#             },
#         }
#     )
#
#     accept = "application/json"
#     contentType = "application/json"
#     response = bedrock_runtime.invoke_model(
#         body=body, modelId=model_id, accept=accept, contentType=contentType
#     )
#     response_body = json.loads(response["body"].read())
#
#     return response_body["results"][0]["outputText"]
#
#
# if "messages" not in st.session_state:
#     st.session_state.messages = []
#
# for message in st.session_state.messages:
#     with st.chat_message(message["role"]):
#         st.markdown(message["content"])
#
# if prompt := st.chat_input(
#         "What's Up?"
# ):
#     st.session_state.messages.append({"role": "user", "content": prompt})
#     with st.chat_message("user"):
#         st.markdown(prompt)
#
#     with st.chat_message("assistant"):
#         message_placeholder = st.empty()
#         full_response = ""
#
#         result = send_prompt(
#             prompt,
#             model_id="amazon.titan-text-express-v1"
#         )
#
#         # Simulate stream of response with milliseconds delay
#         for chunk in result.split():
#             full_response += chunk + " "
#             time.sleep(0.05)
#             # Add a blinking cursor to simulate typing
#             message_placeholder.markdown(full_response + "▌")
#
#         message_placeholder.markdown(full_response)
#
#     st.session_state.messages.append({"role": "assistant", "content": full_response})
