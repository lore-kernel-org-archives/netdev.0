From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: drivers/net/ipg.h: removed duplicated include
Date: Sat, 07 Jun 2008 07:35:37 +0800
Message-ID: <20080607073340.A07B.WEIYI.HUANG@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com, sorbica@icplus.com.tw, jesse@icplus.com.tw
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:55704 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754017AbYFFXfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 19:35:37 -0400
Received: by wa-out-1112.google.com with SMTP id j37so904633waf.23
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2008 16:35:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed duplicated include <linux/version.h>
in drivers/net/ipg.h

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>

diff --git a/drivers/net/ipg.h b/drivers/net/ipg.h
index cda5388..fadcacb 100644
--- a/drivers/net/ipg.h
+++ b/drivers/net/ipg.h
@@ -21,7 +21,6 @@
 #include <linux/etherdevice.h>
 #include <linux/init.h>
 #include <linux/skbuff.h>
-#include <linux/version.h>
 #include <asm/bitops.h>

 /*

