From: cranium2003 <cranium2003@yahoo.com>
Subject: kernel routing tables
Date: Wed, 6 Apr 2005 04:33:40 -0700 (PDT)
Message-ID: <20050406113340.20995.qmail@web41426.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: net dev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

        I want to know the structure where kernel
stores kernel routing table. When i browse code i
found fib_hash.c,fib_sematics.c and fib_frontend.c
which contains functions to display routing table by
/proc/net/route.
       I want to know is that possible for me to write
a kernel module and take the instance of routing table
and display whole routing table in my kernel module
program? How to do that? does i use struct fib_info in
my kernel modules and us it to print its contents as
kernel routing table?
regards,
cranium.



		
__________________________________ 
Yahoo! Messenger 
Show us what our next emoticon should look like. Join the fun. 
http://www.advision.webevents.yahoo.com/emoticontest
