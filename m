From: prashant s <sree_prash@yahoo.com>
Subject: help on NAPI
Date: Sat, 24 Apr 2004 13:33:01 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040424203301.76624.qmail@web60208.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

sir,
 i have a doubt regarding the NAPI feature which is
introduced in 2.6.3 linux.
 i did not find any performance difference between the
NAPI driver (rtl 8139too 2.6.3 linux) and non NAPI
driver(rtl 8139too 2.4.20 linux) both of them showed
94Mbps(packet size of 1500bytes). The network card
which i used was a 100Mbps real tek card, and the
machine was a p 4. but when i reduced the DMA receive
ring size from 32K to 8k the NAPI driver showed 94Mbps
where as the non NAPI driver showed 72Mbps.
 why is this performance difference when the ring size
is reduced.
 waiting for your reply.

prashant


=09
	=09
__________________________________
Do you Yahoo!?
Yahoo! Photos: High-quality 4x6 digital prints for 25=A2
http://photos.yahoo.com/ph/print_splash
