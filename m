From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH] isdn/gigaset: cede maintainership
Date: Sat, 02 May 2015 19:23:22 +0200
Message-ID: <5545080A.9040005@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	=?UTF-8?B?SGFuc2rDtnJnIExpcHA=?= <hjlipp@web.de>,
	ISDN4Linux Mailing List <isdn4linux@listserv.isdn4linux.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linux Networking Mailing List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As German phone operators are discontinuing ISDN service, neither
Hansj=C3=B6rg nor I will be able to maintain the Gigaset ISDN drivers
any longer. Paul Bolle offered to step into the breach for odd
fixes.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
Acked-by: Paul Bolle <pebolle@tiscali.nl>
---
 MAINTAINERS | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 2e5bbc0..718282d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4364,11 +4364,10 @@ F:      fs/gfs2/
 F:     include/uapi/linux/gfs2_ondisk.h

 GIGASET ISDN DRIVERS
-M:     Hansjoerg Lipp <hjlipp@web.de>
-M:     Tilman Schmidt <tilman@imap.cc>
+M:     Paul Bolle <pebolle@tiscali.nl>
 L:     gigaset307x-common@lists.sourceforge.net
 W:     http://gigaset307x.sourceforge.net/
-S:     Maintained
+S:     Odd Fixes
 F:     Documentation/isdn/README.gigaset
 F:     drivers/isdn/gigaset/
 F:     include/uapi/linux/gigaset_dev.h
--
1.9.2.459.g68773ac

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=C3=B6ffnet mindestens haltbar bis: (siehe R=C3=BCckseite)
