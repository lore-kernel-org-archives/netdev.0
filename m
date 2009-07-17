From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] Update Andreas Koensgen's email address
Date: Fri, 17 Jul 2009 15:47:19 +0100
Message-ID: <20090717144719.GA16470@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andreas Koensgen <ajk@comnets.uni-bremen.de>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934167AbZGQOrN@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The kernel has used a stale email address of Andreas for a few years.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
---
I've checked with Andreas; he's ok with this update.

diff --git a/CREDITS b/CREDITS
index 2b88fb3..e76d300 100644
--- a/CREDITS
+++ b/CREDITS
@@ -1856,7 +1856,7 @@ E: rfkoenig@immd4.informatik.uni-erlangen.de
 D: The Linux Support Team Erlangen
=20
 N: Andreas Koensgen
-E: ajk@iehk.rwth-aachen.de
+E: ajk@comnets.uni-bremen.de
 D: 6pack driver for AX.25
=20
 N: Harald Koerfgen
diff --git a/Documentation/networking/6pack.txt b/Documentation/network=
ing/6pack.txt
index d0777a1..8f33942 100644
--- a/Documentation/networking/6pack.txt
+++ b/Documentation/networking/6pack.txt
@@ -1,7 +1,7 @@
 This is the 6pack-mini-HOWTO, written by
=20
 Andreas K=F6nsgen DG3KQ
-Internet: ajk@iehk.rwth-aachen.de
+Internet: ajk@comnets.uni-bremen.de
 AMPR-net: dg3kq@db0pra.ampr.org
 AX.25:    dg3kq@db0ach.#nrw.deu.eu
=20
diff --git a/MAINTAINERS b/MAINTAINERS
index 18c3f0c..53db744 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -150,7 +150,7 @@ F:	drivers/scsi/53c700*
=20
 6PACK NETWORK DRIVER FOR AX.25
 P:	Andreas Koensgen
-M:	ajk@iehk.rwth-aachen.de
+M:	ajk@comnets.uni-bremen.de
 L:	linux-hams@vger.kernel.org
 S:	Maintained
 F:	drivers/net/hamradio/6pack.c
diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.=
c
index 1551600..981ab53 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -3,7 +3,7 @@
  *		devices like TTY. It interfaces between a raw TTY and the
  *		kernel's AX.25 protocol layers.
  *
- * Authors:	Andreas K=F6nsgen <ajk@iehk.rwth-aachen.de>
+ * Authors:	Andreas K=F6nsgen <ajk@comnets.uni-bremen.de>
  *              Ralf Baechle DL5RB <ralf@linux-mips.org>
  *
  * Quite a lot of stuff "stolen" by Joerg Reuter from slip.c, written =
by
