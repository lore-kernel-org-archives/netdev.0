From: henrik@austad.us
Subject: [TSN RFC v2 9/9] MAINTAINERS: add TSN/AVB-entries
Date: Fri, 16 Dec 2016 18:59:13 +0100
Message-ID: <1481911153-549-10-git-send-email-henrik@austad.us>
References: <1481911153-549-1-git-send-email-henrik@austad.us>
Cc: Richard Cochran <richardcochran@gmail.com>, henrik@austad.us,
        Henrik Austad <haustad@cisco.com>, linux-media@vger.kernel.org,
        alsa-devel@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:36364 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756693AbcLPSAJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 13:00:09 -0500
Received: by mail-lf0-f68.google.com with SMTP id o20so1899541lfg.3
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2016 10:00:08 -0800 (PST)
In-Reply-To: <1481911153-549-1-git-send-email-henrik@austad.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Henrik Austad <haustad@cisco.com>

Not sure how relevant this is other than making a point about
maintaining it.

Signed-off-by: Henrik Austad <haustad@cisco.com>
---
 MAINTAINERS | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 63cefa6..7c5afd2 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -12295,6 +12295,20 @@ T:	git git://linuxtv.org/anttip/media_tree.git
 S:	Maintained
 F:	drivers/media/tuners/tua9001*
 
+TSN CORE DRIVER
+M:	Henrik Austad <haustad@cisco.com>
+L:	linux-kernel@vger.kernel.org
+S:	Supported
+F:	drivers/net/tsn/
+F:	include/linux/tsn.h
+F:	include/trace/events/tsn.h
+
+TSN_AVB_DRIVER
+M:	Henrik Austad <haustad@cisco.com>
+L:	alsa-devel@alsa-project.org (moderated for non-subscribers)
+S:	Supported
+F:	drivers/media/avb/
+
 TULIP NETWORK DRIVERS
 L:	netdev@vger.kernel.org
 L:	linux-parisc@vger.kernel.org
-- 
2.7.4
