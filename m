From: djduanjiong@gmail.com
Subject: [PATCH] libertas: remove duplicated include
Date: Tue, 17 Jul 2012 18:32:28 +0800
Message-ID: <1342521148-18973-1-git-send-email-djduanjiong@gmail.com>
Cc: netdev@vger.kernel.org, Duan Jiong <djduanjiong@gmail.com>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:50251 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752759Ab2GQKdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 06:33:01 -0400
Received: by ghrr11 with SMTP id r11so191084ghr.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 03:33:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <djduanjiong@gmail.com>


Signed-off-by: Duan Jiong <djduanjiong@gmail.com>
---
 drivers/net/wireless/libertas/firmware.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/wireless/libertas/firmware.c b/drivers/net/wireless/libertas/firmware.c
index 601f207..c0f9e7e 100644
--- a/drivers/net/wireless/libertas/firmware.c
+++ b/drivers/net/wireless/libertas/firmware.c
@@ -4,9 +4,7 @@
 
 #include <linux/sched.h>
 #include <linux/firmware.h>
-#include <linux/firmware.h>
 #include <linux/module.h>
-#include <linux/sched.h>
 
 #include "dev.h"
 #include "decl.h"
-- 
1.7.9.5
