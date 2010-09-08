From: Joe Perches <joe@perches.com>
Subject: [PATCH] MAINTAINERS: Add CAIF
Date: Tue, 07 Sep 2010 23:33:24 -0700
Message-ID: <1283927604.2479.1.camel@Joe-Laptop>
References: <1283880791.23280.153.camel@Joe-Laptop>
	 <81C3A93C17462B4BBD7E272753C1057916DE7CC568@EXDCVYMBSTM005.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Sjur BRENDELAND <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1522 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750893Ab0IHGdZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Sep 2010 02:33:25 -0400
In-Reply-To: <81C3A93C17462B4BBD7E272753C1057916DE7CC568@EXDCVYMBSTM005.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 MAINTAINERS |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index c36f5d7..f2b3ece 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1445,6 +1445,16 @@ S:	Maintained
 F:	Documentation/video4linux/cafe_ccic
 F:	drivers/media/video/cafe_ccic*
 
+CAIF NETWORK LAYER
+M:	Sjur Braendeland <sjur.brandeland@stericsson.com>
+L:	netdev@vger.kernel.org
+S:	Supported
+F:	Documentation/networking/caif/
+F:	drivers/net/caif/
+F:	include/linux/caif/
+F:	include/net/caif/
+F:	net/caif/
+
 CALGARY x86-64 IOMMU
 M:	Muli Ben-Yehuda <muli@il.ibm.com>
 M:	"Jon D. Mason" <jdmason@kudzu.us>


