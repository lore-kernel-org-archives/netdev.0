From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH] MAINTAINERS: Drop myself as xen netback maintainer
Date: Fri, 19 Feb 2016 11:44:51 +0000
Message-ID: <1455882291-1867-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:15905 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1427711AbcBSLox (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 06:44:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wei has been picking this up for quite a while now.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
---
 MAINTAINERS | 1 -
 1 file changed, 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 28eb61b..ef30060 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -12013,7 +12013,6 @@ F:	arch/arm64/xen/
 F:	arch/arm64/include/asm/xen/
 
 XEN NETWORK BACKEND DRIVER
-M:	Ian Campbell <ian.campbell@citrix.com>
 M:	Wei Liu <wei.liu2@citrix.com>
 L:	xen-devel@lists.xenproject.org (moderated for non-subscribers)
 L:	netdev@vger.kernel.org
-- 
2.1.4
