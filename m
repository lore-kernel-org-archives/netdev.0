From: linux lover <linux_lover2004@yahoo.com>
Subject: tcp packet building problem
Date: Tue, 12 Apr 2005 03:08:41 -0700 (PDT)
Message-ID: <20050412100841.53540.qmail@web52207.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello,
       I am studying kernel 2.4.20-8 kernel on RH9 and
found that for UDP and ICMP packets skb_reserve is
used for EThernet header but why TCP packet routines
ip_queue_xmit & ip_queue_xmit2 are not using
skb_reserve for Ethernet header? Where is header room
is allocated for ethernet? 
       If i am missing something please point out me.
Thanks in advance.
regards,
linux_lover.


		
__________________________________ 
Yahoo! Mail Mobile 
Take Yahoo! Mail with you! Check email on your mobile phone. 
http://mobile.yahoo.com/learn/mail 
