From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.9 2/11] e100: Add MODULE_VERSION
Date: Wed, 20 Oct 2004 14:34:44 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020143444.P8775@tuxdriver.com>
References: <20041020141146.C8775@tuxdriver.com> <20041020141552.E8775@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, jgarzik@pobox.com,
        john.ronciak@intel.com, ganesh.venkatesan@intel.com
Content-Disposition: inline
In-Reply-To: <20041020141552.E8775@tuxdriver.com>; from linville@tuxdriver.com on Wed, Oct 20, 2004 at 02:15:52PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add MODULE_VERSION to e100 driver.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/e100.c |    1 +
 1 files changed, 1 insertion(+)

Re-send -- forgot Signed-off-by line...

--- linux-2.6.9/drivers/net/e100.c.orig
+++ linux-2.6.9/drivers/net/e100.c
@@ -166,6 +166,7 @@
 MODULE_DESCRIPTION(DRV_DESCRIPTION);
 MODULE_AUTHOR(DRV_COPYRIGHT);
 MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
 
 static int debug = 3;
 module_param(debug, int, 0);
