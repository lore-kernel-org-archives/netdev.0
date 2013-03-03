From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 05/14] MAINTAINERS: remove drivers/net/wan/cycx*
Date: Sat,  2 Mar 2013 22:53:43 -0300
Message-ID: <1362275632-20242-6-git-send-email-cesarb@cesarb.net>
References: <1362275632-20242-1-git-send-email-cesarb@cesarb.net>
Cc: linux-kernel@vger.kernel.org, Joe Perches <joe@perches.com>,
	Cesar Eduardo Barros <cesarb@cesarb.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362275632-20242-1-git-send-email-cesarb@cesarb.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This driver was removed by commit 6fcdf4f (wanrouter: delete now
orphaned header content, files/drivers).

Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 MAINTAINERS | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 261b245..e909cd3 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2357,12 +2357,6 @@ W:	http://www.arm.linux.org.uk/
 S:	Maintained
 F:	drivers/video/cyber2000fb.*
 
-CYCLADES 2X SYNC CARD DRIVER
-M:	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
-W:	http://oops.ghostprotocols.net:81/blog
-S:	Maintained
-F:	drivers/net/wan/cycx*
-
 CYCLADES ASYNC MUX DRIVER
 W:	http://www.cyclades.com/
 S:	Orphan
-- 
1.7.11.7
