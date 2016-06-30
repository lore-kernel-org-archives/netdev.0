From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v2 net-next 1/9] MAINTAINERS: add maintainers for hns driver
Date: Thu, 30 Jun 2016 15:25:01 +0800
Message-ID: <1467271509-63162-2-git-send-email-Yisen.Zhuang@huawei.com>
References: <1467271509-63162-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <akpm@linux-foundation.org>, <gregkh@linuxfoundation.org>,
	<kvalo@codeaurora.org>, <mchehab@osg.samsung.com>,
	<linux@roeck-us.net>, <jslaby@suse.cz>, <yankejian@huawei.com>,
	<huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
	<xieqianqian@huawei.com>, <arnd@arndb.de>, <andrew@lunn.ch>,
	<xypron.glpk@gmx.de>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:38054 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751860AbcF3HHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 03:07:07 -0400
In-Reply-To: <1467271509-63162-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
