From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 47/52] sfc: Don't include net_driver.h from falcon_io.h
Date: Mon, 1 Sep 2008 12:49:54 +0100
Message-ID: <20080901114953.GN7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:57220 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751858AbYIALt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:49:56 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Steve Hodgson <shodgson@solarflare.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon_io.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/falcon_io.h b/drivers/net/sfc/falcon_io.h
index 6670cdf..c16da31 100644
--- a/drivers/net/sfc/falcon_io.h
+++ b/drivers/net/sfc/falcon_io.h
@@ -13,7 +13,6 @@
 
 #include <linux/io.h>
 #include <linux/spinlock.h>
-#include "net_driver.h"
 
 /**************************************************************************
  *
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

