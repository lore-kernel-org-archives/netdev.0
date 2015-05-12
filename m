From: Joe Perches <joe@perches.com>
Subject: [Suggested PATCH] MAINTAINERS: Remove Jitendra Kalsaria from QLogic
 qla3xxx driver
Date: Tue, 12 May 2015 11:50:26 -0700
Message-ID: <1431456626.2884.81.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ron Mercer <ron.mercer@qlogic.com>,
	Ameen Rahman <ameen.rahman@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

He is no longer with QLogic.

The bounce message suggested contacting
	Ameen Rahman <ameen.rahman@qlogic.com>
but I've no idea if Ameen is working on this driver.

Signed-off-by: Joe Perches <joe@perches.com>
---
 MAINTAINERS | 1 -
 1 file changed, 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 3144e6d..5219703 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8045,7 +8045,6 @@ F:	Documentation/scsi/LICENSE.qla4xxx
 F:	drivers/scsi/qla4xxx/
 
 QLOGIC QLA3XXX NETWORK DRIVER
-M:	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
 M:	Ron Mercer <ron.mercer@qlogic.com>
 M:	linux-driver@qlogic.com
 L:	netdev@vger.kernel.org
