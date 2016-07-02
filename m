From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v11 22/22] MAINTAINERS: Add maintainers for HiSilicon RoCE driver
Date: Sat, 2 Jul 2016 17:39:24 +0800
Message-ID: <1467452364-66522-23-git-send-email-oulijun@huawei.com>
References: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
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
In-Reply-To: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch added maintainers for RoCE driver.

Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
Signed-off-by: Lijun Ou <oulijun@huawei.com>
---
PATCH v11/v10/v9:
- No change over the PATCH v8

PATCH v8:
This fixes the comments given by Joe Perches over the PATCH v7:
  Link: https://lkml.org/lkml/2016/5/25/396

PATCH v7/v6/v5/v4:
- No change over the PATCH v3

PATCH v3:
- The initial patch
---
---
 MAINTAINERS | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 0f148d3..71abead 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5422,6 +5422,14 @@ F:	include/uapi/linux/if_hippi.h
 F:	net/802/hippi.c
 F:	drivers/net/hippi/
 
+HISILICON ROCE DRIVER
+M:	Lijun Ou <oulijun@huawei.com>
+M:	Wei Hu(Xavier) <xavier.huwei@huawei.com>
+L:	linux-rdma@vger.kernel.org
+S:	Maintained
+F:	drivers/infiniband/hw/hns/
+F:	Documentation/devicetree/bindings/infiniband/hisilicon-hns-roce.txt
+
 HISILICON SAS Controller
 M:	John Garry <john.garry@huawei.com>
 W:	http://www.hisilicon.com
-- 
1.9.1
