From: linux lover <linux_lover2004@yahoo.com>
Subject: how to interpret C statement?
Date: Tue, 8 Jun 2004 08:44:12 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040608154412.14868.qmail@web52208.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="0-321018539-1086709452=:14820"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0-321018539-1086709452=:14820
Content-Type: text/plain; charset=us-ascii

how to interpret following C statement?
#define TCP_SKB_CB(__skb)       ((struct tcp_skb_cb *)&((__skb)->cb[0]))
what is use of tcp_skb_cb structure in kernel source tcp.h? how TCP_SKB_CB(skb) is translated in its definition?
regards,
linux_lover





		
---------------------------------
Do you Yahoo!?
Friends.  Fun. Try the all-new Yahoo! Messenger
--0-321018539-1086709452=:14820
Content-Type: text/html; charset=us-ascii

<DIV>
<DIV>
<DIV>
<DIV>how to interpret following C statement?<BR>#define TCP_SKB_CB(__skb)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ((struct tcp_skb_cb *)&amp;((__skb)-&gt;cb[0]))</DIV>
<DIV>what is use of tcp_skb_cb structure in kernel source tcp.h? how TCP_SKB_CB(skb) is translated in its definition?</DIV>
<DIV>regards,<BR>linux_lover<BR></DIV></DIV></DIV></DIV><p>
		<hr size=1><font face=arial size=-1>Do you Yahoo!?<br>Friends.  Fun. <a href="http://messenger.yahoo.com/">Try the all-new Yahoo! Messenger</a>
--0-321018539-1086709452=:14820--
