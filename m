From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v3 9/9] forcedeth: whitespace/indentation fixes
Date: Mon, 14 Nov 2011 16:11:19 -0800
Message-ID: <3fd2c7d9fff1284986a80c9df025bb91a653e956.1321313729.git.david.decotigny@google.com>
References: <cover.1321313729.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f74.google.com ([74.125.82.74]:41745 "EHLO
	mail-ww0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756844Ab1KOALw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 19:11:52 -0500
Received: by mail-ww0-f74.google.com with SMTP id 5so124194wwe.1
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2011 16:11:51 -0800 (PST)
In-Reply-To: <cover.1321313729.git.david.decotigny@google.com>
In-Reply-To: <cover.1321313729.git.david.decotigny@google.com>
References: <cover.1321313729.git.david.decotigny@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 50133f1..3b4b706 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -65,7 +65,7 @@
 #include <linux/slab.h>
 #include <linux/uaccess.h>
 #include <linux/prefetch.h>
-#include  <linux/io.h>
+#include <linux/io.h>
 
 #include <asm/irq.h>
 #include <asm/system.h>
-- 
1.7.3.1
