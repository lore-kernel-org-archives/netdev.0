From: Joe Perches <joe@perches.com>
Subject: [PATCH] MAINTAINERS: additional NETWORKING [GENERAL] and
 NETWORKING DRIVERS patterns
Date: Fri, 07 Aug 2009 09:43:01 -0700
Message-ID: <1249663381.3467.80.camel@Joe-Laptop.home>
References: <20090618183738.662f7ef1@emcraft.com>
	 <20090807153106.335b1b8f@emcraft.com>
	 <20090807.090353.191304972.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: sposelenov@emcraft.com, linux-kernel@vger.kernel.org, wd@denx.de,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754148AbZHGQnQ@vger.kernel.org>
In-Reply-To: <20090807.090353.191304972.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-08-07 at 09:03 -0700, David Miller wrote:
> From: Sergei Poselenov <sposelenov@emcraft.com>
> > Unfortunately, received no replies, but the problem still persists.
> I guarantee you'll get more responses if you send networking bug
> reports at least CC:'d to netdev@vger.kernel.org

Perhaps this will help get cc's to the right places.

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index b1114cf..0b697a1 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3555,6 +3555,9 @@ T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
 S:	Maintained
 F:	net/
 F:	include/net/
+F:	include/linux/in.h
+F:	include/linux/net.h
+F:	include/linux/netdevice.h
 
 NETWORKING [IPv4/IPv6]
 M:	"David S. Miller" <davem@davemloft.net>
@@ -3590,6 +3593,8 @@ W:	http://www.linuxfoundation.org/en/Net
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
 S:	Odd Fixes
 F:	drivers/net/
+F:	include/linux/if_*
+F:	include/linux/*device.h
 
 NETXEN (1/10) GbE SUPPORT
 M:	Dhananjay Phadke <dhananjay@netxen.com>
