From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH v2 net-next 2/2] sundance: Add myself as a maintainer
Date: Sat, 17 Aug 2013 09:08:49 +0400
Message-ID: <1376716129-2533-2-git-send-email-kda@linux-powerpc.org>
References: <1376716129-2533-1-git-send-email-kda@linux-powerpc.org>
Cc: Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:61938 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489Ab3HQJDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 05:03:14 -0400
Received: by mail-la0-f49.google.com with SMTP id ev20so2110889lab.8
        for <netdev@vger.kernel.org>; Sat, 17 Aug 2013 02:03:13 -0700 (PDT)
In-Reply-To: <1376716129-2533-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 MAINTAINERS | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 1c6f9db..a83dd4f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7973,6 +7973,12 @@ F:	arch/m68k/sun3*/
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
