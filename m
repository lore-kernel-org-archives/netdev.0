From: joe@perches.com
Subject: [PATCH] [432/2many] MAINTAINERS - SIS 190 ETHERNET DRIVER
Date: Sun, 12 Aug 2007 23:35:42 -0700
Message-ID: <46bffbbe.0ZQs53IlZYhKFIZf%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, romieu@fr.zoreil.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1800 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967292AbXHMGfz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:35:55 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 71be2f5..38f1b0d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4119,6 +4119,7 @@ P:	Francois Romieu
 M:	romieu@fr.zoreil.com
 L:	netdev@vger.kernel.org
 S:	Maintained
+F:	drivers/net/sis190.c
 
 SIS 5513 IDE CONTROLLER DRIVER
 P:	Lionel Bouton
