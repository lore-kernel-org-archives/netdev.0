From: Song Wang <wsonguci@yahoo.com>
Subject: [Routing] Performance Comparison between 2.6 and 2.4 kernel
Date: Fri, 10 Sep 2004 17:52:45 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040911005245.61679.qmail@web40007.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm looking for the network packet routing
performance comparison between the latest 2.4
and 2.6 kernel.

I did some initial testing on my mips-based router.
2.6 kernel (2.6.8.1) performed way below 2.4 kernel
(2.4.17). It sucks. Turning on preemption on 2.6 
kernel even makes routing performance worse.

Anybody did a comprehensive study on the routing
performance for 2.6 and 2.4 kernel?

Thanks.


		
__________________________________
Do you Yahoo!?
Y! Messenger - Communicate in real time. Download now. 
http://messenger.yahoo.com
