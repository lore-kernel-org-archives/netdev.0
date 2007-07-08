From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [NET]: Another unnecessary net/tcp.h inclusion in net/dn.h
Date: Sun, 8 Jul 2007 18:26:26 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0707081739370.29874@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1453638256-1183905629=:29874"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43905 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753960AbXGHP02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jul 2007 11:26:28 -0400
Content-ID: <Pine.LNX.4.64.0707081826060.29874@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1453638256-1183905629=:29874
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0707081826061.29874@kivilampi-30.cs.helsinki.fi>


No longer needed.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/dn.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/net/dn.h b/include/net/dn.h
index ac4ce90..6277783 100644
--- a/include/net/dn.h
+++ b/include/net/dn.h
@@ -3,7 +3,6 @@
 
 #include <linux/dn.h>
 #include <net/sock.h>
-#include <net/tcp.h>
 #include <asm/byteorder.h>
 
 #define dn_ntohs(x) le16_to_cpu(x)
-- 
1.5.0.6
---696243703-1453638256-1183905629=:29874--
