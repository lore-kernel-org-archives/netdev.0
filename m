From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 01/14] MAINTAINERS: remove 3c505
Date: Sat,  2 Mar 2013 22:53:39 -0300
Message-ID: <1362275632-20242-2-git-send-email-cesarb@cesarb.net>
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

This driver was removed by commit 0e245db (drivers/net: delete the 3Com
3c505/3c507 intel i825xx support).

Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Philip Blundell <philb@gnu.org>
Cc: netdev@vger.kernel.org
Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 MAINTAINERS | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index aea0adf..5b64aa5 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -114,12 +114,6 @@ Maintainers List (try to look for most precise areas first)
 
 		-----------------------------------
 
-3C505 NETWORK DRIVER
-M:	Philip Blundell <philb@gnu.org>
-L:	netdev@vger.kernel.org
-S:	Maintained
-F:	drivers/net/ethernet/i825xx/3c505*
-
 3C59X NETWORK DRIVER
 M:	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
 L:	netdev@vger.kernel.org
-- 
1.7.11.7
