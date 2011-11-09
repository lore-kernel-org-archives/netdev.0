From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v1 9/9] forcedeth: whitespace/indentation fixes
Date: Wed,  9 Nov 2011 14:09:23 -0800
Message-ID: <9bd6b5433ed16ce2f7e5b1af92850272da61567b.1320875577.git.david.decotigny@google.com>
References: <cover.1320875577.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1320875577.git.david.decotigny@google.com>
In-Reply-To: <cover.1320875577.git.david.decotigny@google.com>
References: <cover.1320875577.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 2e45a45..669578f 100644
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
