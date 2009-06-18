From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [ofa-general][PATCH 1/2] mlx4: Support ConnectX new device ID: 0x6764
Date: Thu, 18 Jun 2009 15:36:50 +0300
Message-ID: <4A3A34E2.8040500@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 018348c..57326f9 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -1285,6 +1285,7 @@ static struct pci_device_id mlx4_pci_table[] = {
 	{ PCI_VDEVICE(MELLANOX, 0x6750) }, /* MT25408 "Hermon" EN 10GigE PCIe gen2 */
 	{ PCI_VDEVICE(MELLANOX, 0x6372) }, /* MT25458 ConnectX EN 10GBASE-T 10GigE */
 	{ PCI_VDEVICE(MELLANOX, 0x675a) }, /* MT25458 ConnectX EN 10GBASE-T+Gen2 10GigE */
+	{ PCI_VDEVICE(MELLANOX, 0x6764) }, /* MT26468 ConnectX EN 10GigE, PCIe, 2.0 5Gt/s */
 	{ 0, }
 };
 
-- 
1.6.0
