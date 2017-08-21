From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V8 net-next 22/22] net-next/hinic: Add Maintainer
Date: Mon, 21 Aug 2017 23:56:08 +0800
Message-ID: <21252aa5bc4d7c1c9619dab32d664289521744a0.1503330614.git.aviad.krawczyk@huawei.com>
References: <cover.1503330613.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <aviad.krawczyk@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1503330613.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update MAINTAINERS file

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 MAINTAINERS | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 0e967b3..8f9ea9b 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6240,6 +6240,13 @@ L:	linux-input@vger.kernel.org
 S:	Maintained
 F:	drivers/input/touchscreen/htcpen.c
 
+HUAWEI ETHERNET DRIVER
+M:	Aviad Krawczyk <aviad.krawczyk@huawei.com>
+L:	netdev@vger.kernel.org
+S:	Supported
+F:	Documentation/networking/hinic.txt
+F:	drivers/net/ethernet/huawei/hinic/
+
 HUGETLB FILESYSTEM
 M:	Nadia Yvette Chambers <nyc@holomorphy.com>
 S:	Maintained
-- 
1.9.1
