From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 07/14] MAINTAINERS: remove eexpress
Date: Sat,  2 Mar 2013 22:53:45 -0300
Message-ID: <1362275632-20242-8-git-send-email-cesarb@cesarb.net>
References: <1362275632-20242-1-git-send-email-cesarb@cesarb.net>
Cc: linux-kernel@vger.kernel.org, Joe Perches <joe@perches.com>,
	Cesar Eduardo Barros <cesarb@cesarb.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Philip Blundell <philb@gnu.org>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362275632-20242-1-git-send-email-cesarb@cesarb.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This driver was removed by commit f84932d (drivers/net: delete ISA intel
eexpress and eepro i825xx drivers).

Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Philip Blundell <philb@gnu.org>
Cc: netdev@vger.kernel.org
Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 MAINTAINERS | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 2e1443c..92718d8 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3057,12 +3057,6 @@ T:	git git://git.kernel.org/pub/scm/linux/kernel/git/kristoffer/linux-hpc.git
 F:	drivers/video/s1d13xxxfb.c
 F:	include/video/s1d13xxxfb.h
 
-ETHEREXPRESS-16 NETWORK DRIVER
-M:	Philip Blundell <philb@gnu.org>
-L:	netdev@vger.kernel.org
-S:	Maintained
-F:	drivers/net/ethernet/i825xx/eexpress.*
-
 ETHERNET BRIDGE
 M:	Stephen Hemminger <stephen@networkplumber.org>
 L:	bridge@lists.linux-foundation.org
-- 
1.7.11.7
