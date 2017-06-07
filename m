From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH 1/9] net: mvmdio: reorder headers alphabetically
Date: Wed,  7 Jun 2017 10:38:02 +0200
Message-ID: <20170607083810.30922-2-antoine.tenart@free-electrons.com>
References: <20170607083810.30922-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
 Antoine Tenart <antoine.tenart@free-electrons.com>, linux@armlinux.org.uk,
 mw@semihalf.com, linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
 gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com,
 f.fainelli@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170607083810.30922-1-antoine.tenart@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Cosmetic fix reordering headers alphabetically.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvmdio.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 90a60b98c28e..109a2bff334d 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -17,16 +17,16 @@
  * warranty of any kind, whether express or implied.
  */
 
+#include <linux/clk.h>
+#include <linux/delay.h>
+#include <linux/interrupt.h>
+#include <linux/io.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/mutex.h>
+#include <linux/of_mdio.h>
 #include <linux/phy.h>
-#include <linux/interrupt.h>
 #include <linux/platform_device.h>
-#include <linux/delay.h>
-#include <linux/io.h>
-#include <linux/clk.h>
-#include <linux/of_mdio.h>
 #include <linux/sched.h>
 #include <linux/wait.h>
 
-- 
2.9.4
