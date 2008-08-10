From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: drivers/net/ipg.h: remove duplicated #include
Date: Sun, 10 Aug 2008 20:52:21 +0800
Message-ID: <20080810204944.2EF4.WEIYI.HUANG@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com, jgarzik@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.188]:34722 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753550AbYHJMw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2008 08:52:26 -0400
Received: by ti-out-0910.google.com with SMTP id b6so828328tic.23
        for <netdev@vger.kernel.org>; Sun, 10 Aug 2008 05:52:23 -0700 (PDT)
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

