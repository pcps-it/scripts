#!/usr/bin/python

####################################################################################################
#
# Copyright (c) 2016, JAMF Software, LLC.  All rights reserved.
#
#       Redistribution and use in source and binary forms, with or without
#       modification, are permitted provided that the following conditions are met:
#               * Redistributions of source code must retain the above copyright
#                 notice, this list of conditions and the following disclaimer.
#               * Redistributions in binary form must reproduce the above copyright
#                 notice, this list of conditions and the following disclaimer in the
#                 documentation and/or other materials provided with the distribution.
#               * Neither the name of the JAMF Software, LLC nor the
#                 names of its contributors may be used to endorse or promote products
#                 derived from this software without specific prior written permission.
#
#       THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY
#       EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#       WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#       DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
#       DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#       ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#       SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#   Author: Matt Aebly
#   Last Modified: 09/21/2016
#   Version: 1.02
#	
#	Revisions:
#				1.01: Included logging
#				1.02: Included CSV upload capability
#
#   Description: Deletes Classes from the JSS
#
#   Enter JSS URL as https://yourjssurl.com
#
#   Usage: python Delete-Classes.py
#
#
####################################################################################################

import getpass
import sys
import csv
import xml.etree.cElementTree as etree
import time
import httplib
import urllib2
import socket
import ssl
import json
import base64
import logging


# Force TLS since the JSS now requires TLS+ due to the POODLE vulnerability
class TLS1Connection(httplib.HTTPSConnection):
    def __init__(self, host, **kwargs):
        httplib.HTTPSConnection.__init__(self, host, **kwargs)

    def connect(self):
        sock = socket.create_connection((self.host, self.port), self.timeout, self.source_address)
        if getattr(self, '_tunnel_host', None):
            self.sock = sock
            self._tunnel()

        self.sock = ssl.wrap_socket(sock, self.key_file, self.cert_file, ssl_version=ssl.PROTOCOL_TLSv1)


class TLS1Handler(urllib2.HTTPSHandler):
    def __init__(self):
        urllib2.HTTPSHandler.__init__(self)

    def https_open(self, req):
        return self.do_open(TLS1Connection, req)


class ClassFileProcessor:

    jss_url = ""
    jss_user = ""
    jss_pass = ""
    csv_file_path = ""

    classes = {}
    user_mappings = {}
    site_mappings = {}

    def __init__(self,url,username,password):
        self.jss_url = url
        self.jss_user = username
        self.jss_pass = password

    def addClass(self,class_name,teachers,students,days,times,appletvs,site):
        if class_name in self.classes.keys():
            c = self.classes[class_name]
        else:
            c = JSSClass()

        c.addName(class_name)

        if len(teachers) > 0:
            for t in teachers:
                t_id = self.getUser(t)
                c.addTeacher(t_id)

        if len(students) > 0:
            for s in students:
                s_id = self.getUser(s)
                c.addStudent(s_id)

        if days != "":
            c.addDays(days)

        if len(times) == 2:
           c.addTimes(times)

        if len(appletvs) > 0 and appletvs != "NULL":
            for tv in appletvs:
                pass

        if site != "NULL":
            c.addSite(self.getSite(site))

        self.classes[class_name] = c

    def getUsers(self):

        print "Getting Users"

        usrs = self.get_request("/JSSResource/users")
        for usr in usrs['users']:
            self.user_mappings[usr['name']] = usr['id']
    
    def set_list(self):
        self.csv_file_path = raw_input("CSV File Path: ")
    
    def run(self,csv=False):

        # class_id = self.check_class_id_exists()

        # if class_id == 'N':
        if csv:
            self.set_list()
            class_list = self.get_csv_classes()
			
            print "%d Classes Will Be Removed..." % class_list

    def delete_all_classes(self):
        print "Deleting Classes"

        classes = self.get_request("/JSSResource/classes")

        for c in classes['classes']:
            self.delete_request("/JSSResource/classes/id/%s" % c['id'])

        print "Deleted Classes"
        
    # Get all the class IDs from a csv and remove them from their devices
    def get_csv_classes(self):
        print "Building Class List Based on CSV File"

        classes = 0

        with open(self.csv_file_path.replace('\\','').strip(),'rU') as classes_file:
            classesReader = csv.reader(classes_file,delimiter=',')
            for classRow in classesReader:
                endpoint = "/JSSResource/classes/id/" + str(classRow[0])
                # class_info = self.get_request(endpoint,"json")
                self.delete_request(endpoint)
                classes = classes + 1
                
        return classes

    def get_request(self,api_endpoint,ret_type="json"):
        opener = urllib2.build_opener(TLS1Handler())
        request = urllib2.Request(self.jss_url + api_endpoint)
        request.add_header("Authorization", "Basic " + self.auth_header())
        if ret_type == "json":
            request.add_header("Accept", "application/json")
        else:
            request.add_header("Accept", "application/xml")

        request.get_method = lambda: 'GET'

        try:
            response = opener.open(request)
            logging.info("Doing JSS API Get Request To %s" % api_endpoint)
            if ret_type == "json":
                api_data = json.load(response)
                return api_data
            else:
                return str(response.read())
        except urllib2.HTTPError as e:
            logging.error("Bad Call")
            return {}
        except urllib2.URLError as e:
            logging.error("URL Issues: " + str(e))
            return {}

    def post_request(self,api_endpoint,data):
        opener = urllib2.build_opener(TLS1Handler())
        request = urllib2.Request(self.jss_url + api_endpoint)
        request.add_header("Authorization", "Basic " + self.auth_header())
        request.add_header("Content-Type", "text/xml")
        request.get_method = lambda: 'POST'

        try:
            response = opener.open(request,data)
            logging.info("Doing JSS API Post Request To %s" % api_endpoint)
            return response.read()
        except urllib2.HTTPError as e:
            logging.error("Bad Call %s" % e)
            print e.read()
            return {}
        except urllib2.URLError as e:
            logging.error("URL Issues: %s" % e)
            return {}

    def delete_request(self,api_endpoint):
        opener = urllib2.build_opener(TLS1Handler())
        request = urllib2.Request(self.jss_url + api_endpoint)
        request.add_header("Authorization", "Basic " + self.auth_header())
        request.add_header("Content-Type", "text/xml")
        request.get_method = lambda: 'DELETE'

        try:
            response = opener.open(request)
            logging.info("Doing JSS API Delete Request To %s" % api_endpoint)
            return response.read()
        except urllib2.HTTPError as e:
            logging.error("Bad Call %s" % e)
            print e.read()
            return {}
        except urllib2.URLError as e:
            logging.error("URL Issues: %s" % e)
            return {}

    def auth_header(self):
        return base64.b64encode('%s:%s' % (self.jss_user,self.jss_pass))


class JSSClass:

    def __init__(self):
        self.students = []
        self.teachers = []
        self.start_time = ""
        self.end_time = ""
        self.appletvs = []
        self.class_name = ""
        self.days = ""
        self.site = ""

    def addStudent(self,username):
        self.students.append(username)

    def addTeacher(self,username):
        self.teachers.append(username)

    def addDays(self,days):
        self.days = days

    def addTimes(self,times):
        self.start_time = times[0]
        self.end_time = times[1]

    def addAppleTV(self,appletv):
        self.appletvs.append(appletv)

    def addName(self,name):
        self.class_name = name

    def addSite(self,site):
        self.site = site

    def toXML(self):

        # Start Class XML
        class_xml = etree.Element('class')

        # Class Name
        class_name_xml = etree.Element('name')
        class_name_xml.text = self.class_name

        class_xml.append(class_name_xml)

        # Class Site
        class_site_xml = etree.Element('site')
        class_site_id_xml = etree.Element('id')
        class_site_id_xml.text = str(self.site)
        class_site_xml.append(class_site_id_xml)

        class_xml.append(class_site_xml)

        # Students
        students_xml = etree.Element("student_ids")

        for student in set(self.students):
            student_xml = etree.Element("id")
            student_xml.text = str(student)

            students_xml.append(student_xml)

        class_xml.append(students_xml)

        # Teachers
        teachers_xml = etree.Element("teacher_ids")

        for teacher in set(self.teachers):
            teacher_xml = etree.Element("id")
            teacher_xml.text = str(teacher)

            teachers_xml.append(teacher_xml)

        class_xml.append(teachers_xml)

        # Handle Meeting Days
        meeting_times = etree.Element("meeting_times")
        meeting_time = etree.Element("meeting_time")

        day_xml = etree.Element("days")
        day_xml.text = self.days
        meeting_time.append(day_xml)

        start_time_xml = etree.Element("start_time")
        start_time_xml.text = convert_time(self.start_time)
        meeting_time.append(start_time_xml)

        end_time_xml = etree.Element("end_time")
        end_time_xml.text = convert_time(self.end_time)
        meeting_time.append(end_time_xml)

        meeting_times.append(meeting_time)

        class_xml.append(meeting_times)

        return etree.tostring(class_xml)



'''
Converts a time in minutes

@param String hour and minutes time string

@return String the time formatted into minutes since midnight
'''
def convert_time(time_str):

    ret_val = 0

    if "PM" in time_str:
        ret_val += (60 * 12)

    time_str = time_str.replace("PM","")
    time_str = time_str.replace("AM","")
    time_str = time_str.replace(":","")

    val1 = int(time_str) / 100
    val2 = int(time_str) % 100

    ret_val += (60 * val1)
    ret_val += val2

    return str(ret_val)


def main():
    if len(sys.argv) >= 2:
        jss_url = sys.argv[1]
    else:
        jss_url  = raw_input("JSS URL: ")

    if int(len(sys.argv)) >= 3:
        jss_user = sys.argv[2]
    else:
        jss_user = raw_input("JSS Username: ")

    if int(len(sys.argv)) >= 4:
        jss_pass = sys.argv[3]
    else:
        jss_pass = getpass.getpass("JSS Password: ")

    if int(len(sys.argv)) >= 5:
        supply_list = sys.argv[4]
    else:
        supply_list = raw_input('Using CSV? [Y or N] (Capital Letter): ')

    script_start_time = time.time()
    
    logging.basicConfig(filename="/Users/Shared/delete-classes.log",level=logging.DEBUG,format='%(asctime)s [%(levelname)s] %(message)s')

    logging.info("Deleting Classes")

    cfp = ClassFileProcessor(jss_url,jss_user,jss_pass)

    if supply_list == "N":
        delete_all = raw_input('Delete All Classes? [Y or N] (Capital Letter): ')
        if delete_all == "Y":
            cfp.delete_all_classes()
        elif delete_all == "N":
        	print "No Classes Deleted"
        	exit()
    elif supply_list == "Y":
        cfp.run(True)
    else:
        print "Bad Option Supplied"
        exit()

    script_end_time = time.time()
    script_total_time = script_end_time - script_start_time

    print "Script Running Time %s seconds" % script_total_time

main()