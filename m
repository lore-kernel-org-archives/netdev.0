From: puja <puja.puri@cdac.ernet.in>
Subject: Help on firewall hooks
Date: Wed, 31 Jul 2002 10:04:36 +0530
Sender: owner-netdev@oss.sgi.com
Message-ID: <3D4768DC.7070907@cdac.ernet.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello sir,

I wanted to clarify on some concepts in firewall hooks. I found FW_QUEUE 
as a return type in firewall hook functions in some codes which use 
firewall hooks. I wanted to know the significance of FW_QUEUE. When is 
this used as a return type in firewall hook functions ??

In the tcp/ip code for kernel 2.2.20, in ip_output.c; one of the 
comments says that when call_out_firewall returns FW_QUEUE silently drop 
the skb.
Can you please elaborate on this.


Thanks in advance
Regards
Puja Puri
