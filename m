From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4/4] staging: irda: add a TODO file.
Date: Sun, 27 Aug 2017 17:03:34 +0200
Message-ID: <20170827150334.32495-5-gregkh@linuxfoundation.org>
References: <20170827150334.32495-1-gregkh@linuxfoundation.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        devel@driverdev.osuosl.org,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: davem@davemloft.net, samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170827150334.32495-1-gregkh@linuxfoundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The irda code will be deleted in a future kernel release, so no need to
have anyone do any new work on it.

Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/staging/irda/TODO | 4 ++++
 1 file changed, 4 insertions(+)
 create mode 100644 drivers/staging/irda/TODO

diff --git a/drivers/staging/irda/TODO b/drivers/staging/irda/TODO
new file mode 100644
index 000000000000..7d98a5cffaff
--- /dev/null
+++ b/drivers/staging/irda/TODO
@@ -0,0 +1,4 @@
+The irda code will be removed soon from the kernel tree as it is old and
+obsolete and broken.
+
+Don't worry about fixing up anything here, it's not needed.
-- 
2.14.1
