From: Andrew Morton <akpm@osdl.org>
Subject: Fw: dst cache overflow messages
Date: Sun, 20 Mar 2005 16:37:25 -0800
Message-ID: <20050320163725.4ec79214.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: buakaw@buakaw.homelinux.net
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Sun, 20 Mar 2005 22:51:08 +0200 (EET)
From: buakaw@buakaw.homelinux.net
To: linux-kernel@vger.kernel.org
Subject: 


the system become very laggy.
i use kernel 2.6.10/2.6.11.3 on p4 2.8, msi915p, 3 x 3com905 boomerang.
and the cpu usage normally be about 12% and after something happens it
boost to 100% and it is used mostly by ksoftirqd/0, and a little bit by 
migration/0 and event/0. and in syslog i found thies lines

Mar 20 22:21:09 buakaw kernel: printk: 5543 messages suppressed.
Mar 20 22:21:09 buakaw kernel: dst cache overflow

what can cause this?


