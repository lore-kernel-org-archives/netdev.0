From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: dnet: remove duplicated #include
Date: Wed, 18 Mar 2009 20:21:37 +0800
Message-ID: <49C0E751.4010902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.187]:43495 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779AbZCRMVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 08:21:44 -0400
Received: by ti-out-0910.google.com with SMTP id i7so16879tid.23
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2009 05:21:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed duplicated #include in drivers/net/dnet.c.

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>

diff --git a/drivers/net/dnet.c b/drivers/net/dnet.c
index 5c347f7..8a98d40 100644
--- a/drivers/net/dnet.c
+++ b/drivers/net/dnet.c
@@ -21,7 +21,6 @@
  #include <linux/dma-mapping.h>
  #include <linux/platform_device.h>
  #include <linux/phy.h>
-#include <linux/platform_device.h>

  #include "dnet.h"

