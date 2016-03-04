From: "Wei Hu(Xavier)" <xavier.huwei@huawei.com>
Subject: [PATCH 4/4] infiniband: hns: add Hisilicon RoCE support(Kconfig)
Date: Fri, 4 Mar 2016 16:41:17 +0800
Message-ID: <1457080877-13456-5-git-send-email-xavier.huwei@huawei.com>
References: <1457080877-13456-1-git-send-email-xavier.huwei@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <gongyangming@huawei.com>,
	<xiaokun@huawei.com>, <tangchaofei@huawei.com>,
	<oulijun@huawei.com>, <haifeng.wei@huawei.com>,
	<yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<lisheng011@huawei.com>, <charles.chenxin@huawei.com>,
	<linuxarm@huawei.com>
To: <dledford@redhat.com>, <sean.hefty@intel.com>,
	<hal.rosenstock@gmail.com>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
	<ogerlitz@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457080877-13456-1-git-send-email-xavier.huwei@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This submit add Kconfig.

Signed-off-by: Wei Hu(Xavier) <xavier.huwei@huawei.com>
Signed-off-by: oulijun <oulijun@huawei.com>
---
 drivers/infiniband/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index 8a8440c..c7a24bb 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -73,7 +73,7 @@ source "drivers/infiniband/hw/mlx5/Kconfig"
 source "drivers/infiniband/hw/nes/Kconfig"
 source "drivers/infiniband/hw/ocrdma/Kconfig"
 source "drivers/infiniband/hw/usnic/Kconfig"
-
+source "drivers/infiniband/hw/hisilicon/hns/Kconfig"
 source "drivers/infiniband/ulp/ipoib/Kconfig"
 
 source "drivers/infiniband/ulp/srp/Kconfig"
-- 
1.9.1
