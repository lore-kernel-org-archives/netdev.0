From: joe@perches.com
Subject: [PATCH] [434/2many] MAINTAINERS - SIS 900/7016 FAST ETHERNET
 DRIVER
Date: Sun, 12 Aug 2007 23:35:46 -0700
Message-ID: <46bffbc2.XHtKVR50YxPHDkbZ%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: venza@brownhat.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1941 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967341AbXHMGgs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:36:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 228e077..b74e343 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4135,6 +4135,7 @@ M:	venza@brownhat.org
 W:	http://www.brownhat.org/sis900.html
 L:	netdev@vger.kernel.org
 S:	Maintained
+F:	drivers/net/sis900.*
 
 SIS 96X I2C/SMBUS DRIVER
 P:	Mark M. Hoffman
