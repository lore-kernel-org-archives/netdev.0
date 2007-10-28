From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 04/04] ipg: Kconfig whitepaces/tab damages
Date: Sun, 28 Oct 2007 18:25:01 +0100
Message-ID: <20071028172501.GE24622@electric-eye.fr.zoreil.com>
References: <20071028171937.GA24622@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Avuton Olrich <avuton@gmail.com>,
	Jesse Huang <jesse@icplus.com.tw>,
	Sorbica Shieh <sorbica@icplus.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:48532 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751492AbXJ1Rb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2007 13:31:27 -0400
Content-Disposition: inline
In-Reply-To: <20071028171937.GA24622@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Avuton Olrich <avuton@gmail.com>
Cc: Jesse Huang <jesse@icplus.com.tw>
Cc: Sorbica Shieh <sorbica@icplus.com.tw>
---
 drivers/net/Kconfig |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 9f7ec7d..72d3447 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -166,14 +166,14 @@ config NET_SB1000
 	  If you don't have this card, of course say N.
 
 config IP1000
-       tristate "IP1000 Gigabit Ethernet support"
-       depends on PCI && EXPERIMENTAL
+	tristate "IP1000 Gigabit Ethernet support"
+	depends on PCI && EXPERIMENTAL
 	select MII
-       ---help---
-         This driver supports IP1000 gigabit Ethernet cards.
+	---help---
+	  This driver supports IP1000 gigabit Ethernet cards.
 
-         To compile this driver as a module, choose M here: the module
-         will be called ipg.  This is recommended.
+	  To compile this driver as a module, choose M here: the module
+	  will be called ipg.  This is recommended.
 
 source "drivers/net/arcnet/Kconfig"
 
-- 
1.5.2.4

