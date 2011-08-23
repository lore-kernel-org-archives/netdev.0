From: "Luis R. Rodriguez" <lrodriguez-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: [PATCH] MAINTANERS: update Qualcomm Atheros addresses
Date: Tue, 23 Aug 2011 15:07:31 -0700
Message-ID: <1314137251-32096-1-git-send-email-lrodriguez@qca.qualcomm.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yangjie-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org,
	"Luis R. Rodriguez" <mcgrof-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jouni-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org,
	vthiagar-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org, senthilb-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Luis R. Rodriguez <mcgrof-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>

Qualcomm ate up Atheros, all of the old e-mail addresses
no longer work and e-mails sent to it will bounce. Update
the addresses to the new shiny Qualcomm Atheros (QCA) ones.

Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: jouni-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org
Cc: yangjie-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org
Cc: vthiagar-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org
Cc: senthilb-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org
Signed-off-by: Luis R. Rodriguez <mcgrof-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
---

John, I've left out ath6kl as you removed that so I take it
the respective MAINTAINERS entry was deleted as well (although
I do not see this on wireless-testing.git)

I've thrown in one Ethernet driver maintainers update as well
for QCA, so hope its OK this goes through you. Given that the
e-mail addresses no longer work Cc'ing stable as well.

 MAINTAINERS |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 069ee3b..a286bc8 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1230,7 +1230,7 @@ F:	Documentation/aoe/
 F:	drivers/block/aoe/
 
 ATHEROS ATH GENERIC UTILITIES
-M:	"Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
+M:	"Luis R. Rodriguez" <mcgrof-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
 L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 S:	Supported
 F:	drivers/net/wireless/ath/*
@@ -1238,7 +1238,7 @@ F:	drivers/net/wireless/ath/*
 ATHEROS ATH5K WIRELESS DRIVER
 M:	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
 M:	Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
-M:	"Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
+M:	"Luis R. Rodriguez" <mcgrof-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
 M:	Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>
 L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 L:	ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
@@ -1247,10 +1247,10 @@ S:	Maintained
 F:	drivers/net/wireless/ath/ath5k/
 
 ATHEROS ATH9K WIRELESS DRIVER
-M:	"Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
-M:	Jouni Malinen <jmalinen-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
-M:	Vasanthakumar Thiagarajan <vasanth-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
-M:	Senthil Balasubramanian <senthilkumar-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
+M:	"Luis R. Rodriguez" <mcgrof-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
+M:	Jouni Malinen <jouni-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
+M:	Vasanthakumar Thiagarajan <vthiagar-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
+M:	Senthil Balasubramanian <senthilb-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
 L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 L:	ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org
 W:	http://wireless.kernel.org/en/users/Drivers/ath9k
@@ -1278,7 +1278,7 @@ F:	drivers/input/misc/ati_remote2.c
 ATLX ETHERNET DRIVERS
 M:	Jay Cliburn <jcliburn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
 M:	Chris Snook <chris.snook-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
-M:	Jie Yang <jie.yang-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
+M:	Jie Yang <yangjie-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
 L:	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 W:	http://sourceforge.net/projects/atl1
 W:	http://atl1.sourceforge.net
-- 
1.7.4.15.g7811d

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
