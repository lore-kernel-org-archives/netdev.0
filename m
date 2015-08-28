From: Aleksey Makarov <aleksey.makarov@auriga.com>
Subject: [PATCH net-next 1/8] net: thunderx: fix MAINTAINERS
Date: Fri, 28 Aug 2015 17:59:53 +0300
Message-ID: <1440774004-27923-1-git-send-email-aleksey.makarov@auriga.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Aleksey Makarov <aleksey.makarov@auriga.com>,
 David Daney <david.daney@cavium.com>,
 Sunil Goutham <Sunil.Goutham@caviumnetworks.com>,
 Aleksey Makarov <aleksey.makarov@caviumnetworks.com>,
 linux-kernel@vger.kernel.org,
 Robert Richter <robert.richter@caviumnetworks.com>,
 linux-arm-kernel@lists.infradead.org
To: <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
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

From: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>

The liquidio and thunder drivers have different maintainers.

Signed-off-by: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
---
 MAINTAINERS | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 4e6dcb6..43cf79e 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -928,7 +928,7 @@ M:	Sunil Goutham <sgoutham@cavium.com>
 M:	Robert Richter <rric@kernel.org>
 L:	linux-arm-kernel@lists.infradead.org (moderated for non-subscribers)
 S:	Supported
-F:	drivers/net/ethernet/cavium/
+F:	drivers/net/ethernet/cavium/thunder/
 
 ARM/CIRRUS LOGIC CLPS711X ARM ARCHITECTURE
 M:	Alexander Shiyan <shc_work@mail.ru>
@@ -2543,7 +2543,6 @@ M:     Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
 L:     netdev@vger.kernel.org
 W:     http://www.cavium.com
 S:     Supported
-F:     drivers/net/ethernet/cavium/
 F:     drivers/net/ethernet/cavium/liquidio/
 
 CC2520 IEEE-802.15.4 RADIO DRIVER
-- 
2.5.0
