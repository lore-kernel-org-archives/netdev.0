From: Jie Deng <Jie.Deng1@synopsys.com>
Subject: [PATCH net-next 2/2] net: dwc-xlgmac: add module license
Date: Tue, 21 Mar 2017 11:59:05 +0800
Message-ID: <6b11b3922961333a5a7efb4a1e1a3db047d32a4b.1490067991.git.jiedeng@synopsys.com>
References: <d8c550bcf611f0350058ea8d6a88f99f8a117f06.1490067991.git.jiedeng@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <arnd@arndb.de>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Jie Deng <Jie.Deng1@synopsys.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d8c550bcf611f0350058ea8d6a88f99f8a117f06.1490067991.git.jiedeng@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the warning about missing MODULE_LICENSE().

Signed-off-by: Jie Deng <jiedeng@synopsys.com>
---
 drivers/net/ethernet/synopsys/dwc-xlgmac-common.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c b/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c
index 53ad707..07def2b 100644
--- a/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-common.c
@@ -21,6 +21,8 @@
 #include "dwc-xlgmac.h"
 #include "dwc-xlgmac-reg.h"
 
+MODULE_LICENSE("Dual BSD/GPL");
+
 static int debug = -1;
 module_param(debug, int, 0644);
 MODULE_PARM_DESC(debug, "DWC ethernet debug level (0=none,...,16=all)");
-- 
1.9.1
