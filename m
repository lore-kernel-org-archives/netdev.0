From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] hyper-v: Add myself as additional MAINTAINER
Date: Thu,  5 Jan 2017 09:36:26 -0800
Message-ID: <20170105173626.4657-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        gregkh@linuxfoundation.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net, kys@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the Hyper-V MAINTAINERS to include myself.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index ea11bb03f550..7542341d8155 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5963,6 +5963,7 @@ F:	drivers/media/platform/sti/hva
 Hyper-V CORE AND DRIVERS
 M:	"K. Y. Srinivasan" <kys@microsoft.com>
 M:	Haiyang Zhang <haiyangz@microsoft.com>
+M:	Stephen Hemminger <sthemmin@microsoft.com>
 L:	devel@linuxdriverproject.org
 S:	Maintained
 F:	arch/x86/include/asm/mshyperv.h
-- 
2.11.0
