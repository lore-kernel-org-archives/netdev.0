From: Colin King <colin.king@canonical.com>
Subject: [PATCH] kcm: fix spelling mistake in Kconfig, "connectons"
Date: Tue, 13 Dec 2016 17:30:25 +0000
Message-ID: <20161213173025.24331-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:47784 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753343AbcLMRbB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 12:31:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake "connectons" to "connections" in
Kconfig text.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/kcm/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/kcm/Kconfig b/net/kcm/Kconfig
index 87fca36..23b01e1 100644
--- a/net/kcm/Kconfig
+++ b/net/kcm/Kconfig
@@ -7,5 +7,5 @@ config AF_KCM
 	---help---
 	  KCM (Kernel Connection Multiplexor) sockets provide a method
 	  for multiplexing messages of a message based application
-	  protocol over kernel connectons (e.g. TCP connections).
+	  protocol over kernel connections (e.g. TCP connections).
 
-- 
2.10.2
