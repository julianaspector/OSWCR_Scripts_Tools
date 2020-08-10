from boxsdk import JWTAuth

#Path to JWT config
auth = JWTAuth.from_settings_file('71980991_uastxaq2_config.json')

from boxsdk import Client

client = Client(auth)

# set up webhook on root folder and will work with all subfolders
rootfolder = client.folder(folder_id='110995800136') #Redacted folder

#Set up webhook catcher on Google Sheets
#https://blog.runscope.com/posts/tutorial-capturing-webhooks-with-google-sheets
webhook = client.create_webhook(rootfolder, ['FILE.UPLOADED'], 'https://script.google.com/macros/s/AKfycbz38241QkoV3vmOS-7J1j6dmsf_9W9tZH0_zKysnNT3FTAcaacN/exec')
print('Webhook ID is {0} and the address is {1}'.format(webhook.id, webhook.address))

# delete a webhook
# wh_id = ''
#client.webhook(webhook_id=wh_id).delete()
#print('The webhook was successfully deleted!')

# get list of all active webhooks
#webhooks = client.get_webhooks()
#for webhook in webhooks:
    #print('The webhook ID is {0}'.format(webhook.id))