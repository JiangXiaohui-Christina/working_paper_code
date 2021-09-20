#!/usr/bin/env python
# coding: utf-8

# In[1]:


pip install mysql-connector


# In[2]:


import mysql.connector


# In[18]:


#不要忘记在最后specify是用哪个database
mydb = mysql.connector.connect(host="127.0.0.1", user = "root", password ="[19980202]", port = 3306, database="test")


# In[20]:


mycursor = mydb.cursor()


# In[21]:


mycursor.execute("show databases")


# In[22]:


for i in mycursor:
    print(i)


# In[54]:


mycursor.execute("CREATE TABLE test (title VARCHAR(600), time VARCHAR(600), context MEDIUMTEXT, website VARCHAR(600) PRIMARY KEY)")


# In[48]:


mycursor.execute("DESCRIBE test")


# In[49]:


for x in mycursor:
    print(x)


# In[53]:


mycursor.execute("DROP TABLE test")


# In[56]:


import os
import mysql.connector
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
get_ipython().run_line_magic('matplotlib', 'inline')


# In[60]:


test_tables = pd.read_sql_query("SHOW TABLES FROM test", mydb)


# In[61]:


test_tables


# In[65]:


tables = test_tables['Tables_in_test']


# In[66]:


for table_name in tables:
    output = pd.read_sql_query('DESCRIBE {}'.format(table_name), mydb)
    print(table_name)
    print(output, '\n')


# In[ ]:




