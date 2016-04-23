From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v5 21/21] MAINTAINERS: Add maintainers for HiSilicon RoCE driver
Date: Sat, 23 Apr 2016 18:26:59 +0800
Message-ID: <1461407219-72027-22-git-send-email-oulijun@huawei.com>
References: <1461407219-72027-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <gongyangming@huawei.com>,
	<xiaokun@huawei.com>, <tangchaofei@huawei.com>,
	<oulijun@huawei.com>, <haifeng.wei@huawei.com>,
	<yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<lisheng011@huawei.com>, <charles.chenxin@huawei.com>
To: <dledford@redhat.com>, <sean.hefty@intel.com>,
	<hal.rosenstock@gmail.com>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
	<ogerlitz@mellanox.com>, <linuxarm@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:29920 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752106AbcDWKSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2016 06:18:47 -0400
In-Reply-To: <1461407219-72027-1-git-send-email-oulijun@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch added maintainers for RoCE driver.

Signed-off-by: Lijun Ou <oulijun@huawei.com>
Signed-off-by: Wei Hu(Xavier) <xavier.huwei@huawei.com>
---
 MAINTAINERS | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 61a323a..cb45b6f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -10012,6 +10012,14 @@ W:	http://www.emulex.com
 S:	Supported
 F:	drivers/infiniband/hw/ocrdma/
 
+HISILICON ROCE DRIVER
+M:	Wei Hu(Xavier) <xavier.huwei@huawei.com>
+M:	Lijun Ou <oulijun@huawei.com>
+L:	linux-rdma@vger.kernel.org
+S:	Maintained
+F:	drivers/infiniband/hw/hns/
+F:	Documentation/devicetree/bindings/infiniband/hisilicon-hns-roce.txt
+
 SFC NETWORK DRIVER
 M:	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
 M:	Shradha Shah <sshah@solarflare.com>
-- 
1.9.1
