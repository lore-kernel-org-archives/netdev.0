From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] remove subscribers-only ipvs mailing list
Date: Wed, 15 Dec 2004 02:30:43 +0100
Message-ID: <20041215013043.GI12937@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: wensong@linux-vs.org, ja@ssi.bg
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It's generally agreed, that maintainers mustn't contain subscribers-only 
lists.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.10-rc3-mm1-full/MAINTAINERS.old	2004-12-15 02:28:33.000000000 +0100
+++ linux-2.6.10-rc3-mm1-full/MAINTAINERS	2004-12-15 02:28:43.000000000 +0100
@@ -1595,11 +1595,10 @@
 IPVS
 P:	Wensong Zhang
 M:	wensong@linux-vs.org
 P:	Julian Anastasov
 M:	ja@ssi.bg
-L:	lvs-users@linuxvirtualserver.org
 S:	Maintained
 
 NFS CLIENT
 P:	Trond Myklebust
 M:	trond.myklebust@fys.uio.no
