From: cranium2003 <cranium2003@yahoo.com>
Subject: Tcp sequence number calculation
Date: Sat, 11 Sep 2004 21:40:29 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040912044029.82969.qmail@web41409.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,
 i want know how 2.4 kernel decides which sequence no.
to be sent with next packet?
I am unable to find the location in kernel?
Also what does following statement does?
TCP_SKB_CB(__skb)= ((struct tcp_skb_cb
*)&((__skb)->cb[0]))
in tcp.h 
regards,
cranium2003.


		
_______________________________
Do you Yahoo!?
Shop for Back-to-School deals on Yahoo! Shopping.
http://shopping.yahoo.com/backtoschool
