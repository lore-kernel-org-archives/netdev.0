From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v6 21/21] MAINTAINERS: Add maintainers for HiSilicon RoCE driver
Date: Thu, 28 Apr 2016 20:09:56 +0800
Message-ID: <1461845396-61306-22-git-send-email-oulijun@huawei.com>
References: <1461845396-61306-1-git-send-email-oulijun@huawei.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:60821 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665AbcD1MB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 08:01:29 -0400
In-Reply-To: <1461845396-61306-1-git-send-email-oulijun@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch added maintainers for RoCE driver.

Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
Signed-off-by: Lijun Ou <oulijun@huawei.com>
---
 MAINTAINERS | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 1d5b4be..e7f5284 100644
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
