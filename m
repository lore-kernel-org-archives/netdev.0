From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v9 22/22] MAINTAINERS: Add maintainers for HiSilicon RoCE driver
Date: Wed, 1 Jun 2016 23:38:04 +0800
Message-ID: <1464795484-77395-23-git-send-email-oulijun@huawei.com>
References: <1464795484-77395-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <gongyangming@huawei.com>,
	<xiaokun@huawei.com>, <tangchaofei@huawei.com>,
	<oulijun@huawei.com>, <haifeng.wei@huawei.com>,
	<yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
To: <dledford@redhat.com>, <sean.hefty@intel.com>,
	<hal.rosenstock@gmail.com>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
	<ogerlitz@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464795484-77395-1-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch added maintainers for RoCE driver.

Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
Signed-off-by: Lijun Ou <oulijun@huawei.com>
---
 MAINTAINERS | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 7304d2e..3de2ef0 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -10280,6 +10280,14 @@ W:	http://www.emulex.com
 S:	Supported
 F:	drivers/infiniband/hw/ocrdma/
 
+HISILICON ROCE DRIVER
+M:	Lijun Ou <oulijun@huawei.com>
+M:	Wei Hu(Xavier) <xavier.huwei@huawei.com>
+L:	linux-rdma@vger.kernel.org
+S:	Maintained
+F:	drivers/infiniband/hw/hns/
+F:	Documentation/devicetree/bindings/infiniband/hisilicon-hns-roce.txt
+
 SFC NETWORK DRIVER
 M:	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
 M:	Edward Cree <ecree@solarflare.com>
-- 
1.9.1
