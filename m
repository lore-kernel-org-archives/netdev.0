From: joe@perches.com
Subject: [PATCH] [193/2many] MAINTAINERS - FREESCALE SOC FS_ENET DRIVER
Date: Sun, 12 Aug 2007 23:27:36 -0700
Message-ID: <46bff9d8.wK4SjlojmM1YMQd3%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: vbordug@ru.mvista.com, torvalds@linux-foundation.org,
	pantelis.antoniou@gmail.com, netdev@vger.kernel.org,
	linuxppc-embedded@ozlabs.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4390 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966553AbXHMG1w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:27:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index e06f478..2ef0ec4 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1859,6 +1859,8 @@ M:	vbordug@ru.mvista.com
 L:	linuxppc-embedded@ozlabs.org
 L:	netdev@vger.kernel.org
 S:	Maintained
+F:	drivers/net/fs_enet/
+F:	include/linus/fs_enet_pd.h
 
 FREESCALE HIGHSPEED USB DEVICE DRIVER
 P:	Li Yang
