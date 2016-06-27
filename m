From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 1/9] MAINTAINERS: add maintainers for hns driver
Date: Mon, 27 Jun 2016 17:54:07 +0800
Message-ID: <1467021255-95900-2-git-send-email-Yisen.Zhuang@huawei.com>
References: <1467021255-95900-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ivecera@redhat.com, andrew@lunn.ch, fengguang.wu@intel.com,
 liguozhu@huawei.com, arnd@arndb.de, charles.chenxin@huawei.com,
 linux-kernel@vger.kernel.org, linuxarm@huawei.com, geliangtang@163.com,
 huangdaode@hisilicon.com, netdev@vger.kernel.org,
 andriy.shevchenko@linux.intel.com, linux-arm-kernel@lists.infradead.org
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
 <yankejian@huawei.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1467021255-95900-1-git-send-email-Yisen.Zhuang@huawei.com>
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

From: Daode Huang <huangdaode@hisilicon.com>

This patch adds maintainers for hisilicon network subsystem driver

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
---
 MAINTAINERS | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 3a171a9..c819659 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5421,6 +5421,15 @@ F:	include/uapi/linux/if_hippi.h
 F:	net/802/hippi.c
 F:	drivers/net/hippi/
 
+HISILICON NETWORK SUBSYSTEM DRIVER
+M:	Yisen Zhuang <yisen.zhuang@huawei.com>
+M:	Salil Mehta <salil.mehta@huawei.com>
+L:	netdev@vger.kernel.org
+W:	http://www.hisilicon.com
+S:	Maintained
+F:	drivers/net/ethernet/hisilicon/*
+F:	Documentation/devicetree/bindings/net/hisilicon*.txt
+
 HISILICON SAS Controller
 M:	John Garry <john.garry@huawei.com>
 W:	http://www.hisilicon.com
-- 
1.9.1
