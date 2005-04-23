From: linux lover <linux_lover2004@yahoo.com>
Subject: understandable skbuff behavioural problem
Date: Fri, 22 Apr 2005 21:42:38 -0700 (PDT)
Message-ID: <20050423044239.25347.qmail@web52208.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,
       I am learning the skbuff workings in kenrel for
that I added a fake header in TCP/IP with Fake header
containing 2 fields of type int ipchksum and tcpchksum
taken frpm upper layer and only copied to new header.
I directly push it after IP header is added and thus
sending packets to destination pc. At destination side
i am able to receive application data(payload) indeed
correctly in FTP transfer but how to display those 2
fields in kernel using printk?
      I am really stuck at this point please help me.
Thanks in advance.
regards,
linux_lover

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
