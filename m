From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH net-next 2/2] net-next: sundance: Add myself as an maintainer Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
Date: Fri, 16 Aug 2013 21:00:17 +0400
Message-ID: <1376672417-2798-2-git-send-email-kda@linux-powerpc.org>
References: <1376672417-2798-1-git-send-email-kda@linux-powerpc.org>
Cc: Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:40755 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754314Ab3HPWsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 18:48:11 -0400
Received: by mail-la0-f43.google.com with SMTP id ep20so1984204lab.30
        for <netdev@vger.kernel.org>; Fri, 16 Aug 2013 15:48:09 -0700 (PDT)
In-Reply-To: <1376672417-2798-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
