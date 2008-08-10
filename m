From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: drivers/net/atl1e/atl1e.h: remove duplicated #include
Date: Mon, 11 Aug 2008 06:32:22 +0800
Message-ID: <20080810213024.574D.WEIYI.HUANG@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com, jgarzik@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.185]:24008 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252AbYHJWc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2008 18:32:26 -0400
Received: by ti-out-0910.google.com with SMTP id b6so872728tic.23
        for <netdev@vger.kernel.org>; Sun, 10 Aug 2008 15:32:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed duplicated include <linux/version.h> in
drivers/net/atl1e/atl1e.h

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>

diff --git a/drivers/net/atl1e/atl1e.h b/drivers/net/atl1e/atl1e.h
index b645fa0..c49550d 100644
--- a/drivers/net/atl1e/atl1e.h
+++ b/drivers/net/atl1e/atl1e.h
@@ -46,7 +46,6 @@
 #include <linux/vmalloc.h>
 #include <linux/pagemap.h>
 #include <linux/tcp.h>
-#include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
 #include <linux/workqueue.h>


