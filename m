From: Andrea Shepard <andrea@persephoneslair.org>
Subject: [20/22] Cyclades PC300 driver: add version history for this patch series
Date: Sun, 29 Jan 2012 18:59:35 -0800
Message-ID: <20120130025935.GU10262@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: khc@pm.waw.pl, davem@davemloft.net, mmarek@suse.cz,
	jkosina@suse.cz, joe@perches.com, justinmattock@gmail.com,
	gregkh@suse.de, alan@linux.intel.com, jdmason@kudzu.us
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a comment describing this patch series to the history in pc300_drv.c.

Signed-off-by: Andrea Shepard <andrea@persephoneslair.org>

diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 5e50907..bcdf53a 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -17,6 +17,9 @@ static const char rcsid[] =
  *	
  *	Using tabstop = 4.
  *
+ * Cyclades version 4.1.0 merged in, with new portability fixes,
+ * and ported to recent kernels by Andrea Shepard <andrea@persephoneslair.org>
+ *
  * Due to changes in certain ioctls necessary for portability, this
  * version requires a new version of pc300utils, which may be found
  * at: http://charon.persephoneslair.org/~andrea/software/pc300utils/
