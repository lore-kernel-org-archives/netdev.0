From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH] MAINTAINERS: change IEEE 802.15.4 maintainer
Date: Thu,  3 Jul 2014 23:13:19 +0200
Message-ID: <1404421999-17210-2-git-send-email-alex.aring@gmail.com>
References: <1404421999-17210-1-git-send-email-alex.aring@gmail.com>
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	Alexander Aring <alex.aring@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38106 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129AbaGCVNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 17:13:44 -0400
Received: by mail-wi0-f170.google.com with SMTP id cc10so11381417wib.3
        for <netdev@vger.kernel.org>; Thu, 03 Jul 2014 14:13:43 -0700 (PDT)
In-Reply-To: <1404421999-17210-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the IEEE 802.15.4 subsystem maintainer to Alexander Aring.
We discussed this change before via e-mail and I collected the acks from the
current maintainers.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
Acked-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Acked-by: Alexander Smirnov <alex.bluesman.sminov@gmail.com>
---
 MAINTAINERS | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index f492681..fb3f0fc 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4477,8 +4477,7 @@ S:	Supported
 F:	drivers/idle/i7300_idle.c
 
 IEEE 802.15.4 SUBSYSTEM
-M:	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
-M:	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+M:	Alexander Aring <alex.aring@gmail.com>
 L:	linux-zigbee-devel@lists.sourceforge.net (moderated for non-subscribers)
 W:	http://apps.sourceforge.net/trac/linux-zigbee
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/lowpan/lowpan.git
-- 
2.0.1
