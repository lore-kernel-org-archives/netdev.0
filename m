From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v3 net-next 1/9] MAINTAINERS: add maintainers for hns driver
Date: Fri, 1 Jul 2016 17:34:05 +0800
Message-ID: <1467365653-83331-2-git-send-email-Yisen.Zhuang@huawei.com>
References: <1467365653-83331-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <akpm@linux-foundation.org>, <gregkh@linuxfoundation.org>,
	<kvalo@codeaurora.org>, <mchehab@osg.samsung.com>,
	<linux@roeck-us.net>, <jslaby@suse.cz>, <yankejian@huawei.com>,
	<huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
	<xieqianqian@huawei.com>, <arnd@arndb.de>, <andrew@lunn.ch>,
	<xypron.glpk@gmx.de>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467365653-83331-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daode Huang <huangdaode@hisilicon.com>

This patch adds maintainers for hisilicon network subsystem driver

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
change log:
 v3: match all files in and below drivers/net/ethernet/hisilicon/

 v2: the same as v1

 v1: first submit
  Link: https://lkml.org/lkml/2016/6/27/184
---
 MAINTAINERS | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index d8c0784..772c9ff 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5437,6 +5437,15 @@ F:	include/uapi/linux/if_hippi.h
 F:	net/802/hippi.c
 F:	drivers/net/hippi/
 
+HISILICON NETWORK SUBSYSTEM DRIVER
+M:	Yisen Zhuang <yisen.zhuang@huawei.com>
+M:	Salil Mehta <salil.mehta@huawei.com>
+L:	netdev@vger.kernel.org
+W:	http://www.hisilicon.com
+S:	Maintained
+F:	drivers/net/ethernet/hisilicon/
+F:	Documentation/devicetree/bindings/net/hisilicon*.txt
+
 HISILICON SAS Controller
 M:	John Garry <john.garry@huawei.com>
 W:	http://www.hisilicon.com
-- 
1.9.1
