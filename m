From: Park Lee <parklee_sel@yahoo.com>
Subject: A sending packet and its socket and sock
Date: Thu, 30 Dec 2004 21:22:21 -0800 (PST)
Message-ID: <20041231052221.15578.qmail@web51507.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
    In Linux IP network, when a packet is going to be
sent out. Would you please tell me which one of the
following items is right for the packet (Let's suppose
struct sock *sk; struct socket *skt):
  1), The packet has a sock (i.e. sk!=NULL), but
doesn't has a socket (i.e. skt=NULL) corresponding to
the packet?
  2), The packet has a socket (i.e. skt!=NULL), but
doesn't has a sock (i.e. sk=NULL) corresponding to the
packet?
  3), The packet doesn't has the both (i.e. sk=NULL
and skt=NULL)?
  
  And, If some of them are right, Would you please
also give me some examples of them?

  Thank you very much.



=====
Best Regards,
Park Lee


		
__________________________________ 
Do you Yahoo!? 
Yahoo! Mail - Easier than ever with enhanced search. Learn more.
http://info.mail.yahoo.com/mail_250
