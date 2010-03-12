From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: [PATCH 2/6] net: remove unused #include <linux/version.h>
Date: Fri, 12 Mar 2010 22:12:52 +0800
Message-ID: <1268403172-3956-1-git-send-email-weiyi.huang@gmail.com>
Cc: netdev@vger.kernel.org, Huang Weiyi <weiyi.huang@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:60719 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933244Ab0CLONI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Mar 2010 09:13:08 -0500
Received: by mail-bw0-f209.google.com with SMTP id 1so1060379bwz.21
        for <netdev@vger.kernel.org>; Fri, 12 Mar 2010 06:13:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unused #include <linux/version.h>('s) in
  drivers/net/ksz884x.c

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
---
 drivers/net/ksz884x.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index 7264a3e..f30790b 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -17,7 +17,6 @@
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/ioport.h>
 #include <linux/pci.h>
 #include <linux/proc_fs.h>
-- 
1.6.1.3

