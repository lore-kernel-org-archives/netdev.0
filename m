From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH 2/2] Add myself as an sundance driver maintainer
Date: Fri, 16 Aug 2013 20:32:28 +0400
Message-ID: <1376670748-2084-2-git-send-email-kda@linux-powerpc.org>
References: <1376670748-2084-1-git-send-email-kda@linux-powerpc.org>
Cc: Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:51766 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751839Ab3HPWPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 18:15:51 -0400
Received: by mail-la0-f53.google.com with SMTP id el20so1934698lab.40
        for <netdev@vger.kernel.org>; Fri, 16 Aug 2013 15:15:50 -0700 (PDT)
In-Reply-To: <1376670748-2084-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 MAINTAINERS | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 9ee0a8f..1b3fb7c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7968,6 +7968,12 @@ F:	arch/m68k/sun3*/
 F:	arch/m68k/include/asm/sun3*
 F:	drivers/net/ethernet/i825xx/sun3*
 
+SUNDANCE NETWORK DRIVER
+M:	Denis Kirjanov <kda@linux-powerpc.org>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/ethernet/dlink/sundance.c
+
 SUPERH
 M:	Paul Mundt <lethal@linux-sh.org>
 L:	linux-sh@vger.kernel.org
-- 
1.8.0.2
