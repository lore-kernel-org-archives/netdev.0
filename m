From: joe@perches.com
Subject: [PATCH] [345/2many] MAINTAINERS - NI5010 NETWORK DRIVER
Date: Sun, 12 Aug 2007 23:32:52 -0700
Message-ID: <46bffb14.A5gZ7GgK4qRtZgBX%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, janpascal@vanbest.org, andi@lisas.de,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1341 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967099AbXHMGdW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:33:22 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 1f81c05..35afb38 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3322,6 +3322,7 @@ P:	Andreas Mohr
 M:	andi@lisas.de
 L:	netdev@vger.kernel.org
 S:	Maintained
+F:	drivers/net/ni5010.*
 
 NINJA SCSI-3 / NINJA SCSI-32Bi (16bit/CardBus) PCMCIA SCSI HOST ADAPTER DRIVER
 P:	YOKOTA Hiroshi
