From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.9 8/11] ns83820: Add MODULE_VERSION
Date: Wed, 20 Oct 2004 14:27:56 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020142756.K8775@tuxdriver.com>
References: <20041020141146.C8775@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20041020141146.C8775@tuxdriver.com>; from linville@tuxdriver.com on Wed, Oct 20, 2004 at 02:11:46PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add MODULE_VERSION to ns83820 driver.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/ns83820.c |    1 +
 1 files changed, 1 insertion(+)

--- linux-2.6.9/drivers/net/ns83820.c.ns83820
+++ linux-2.6.9/drivers/net/ns83820.c
@@ -2106,6 +2106,7 @@ static void __exit ns83820_exit(void)
 MODULE_AUTHOR("Benjamin LaHaise <bcrl@redhat.com>");
 MODULE_DESCRIPTION("National Semiconductor DP83820 10/100/1000 driver");
 MODULE_LICENSE("GPL");
+MODULE_VERSION(VERSION);
 
 MODULE_DEVICE_TABLE(pci, ns83820_pci_tbl);
 
