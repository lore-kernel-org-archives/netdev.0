From: joe@perches.com
Subject: [PATCH] [112/2many] MAINTAINERS - BROADCOM B44 10/100 ETHERNET
 DRIVER
Date: Sun, 12 Aug 2007 23:24:55 -0700
Message-ID: <46bff937.AYK9gmwTiXwzbOgL%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: zambrano@broadcom.com, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3940 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966125AbXHMGZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:25:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index a21ccf1..9be0816 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1097,6 +1097,7 @@ P:	Gary Zambrano
 M:	zambrano@broadcom.com
 L:	netdev@vger.kernel.org
 S:	Supported
+F:	drivers/net/b44.*
 
 BROADCOM BNX2 GIGABIT ETHERNET DRIVER
 P:	Michael Chan
