From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita@gmail.com>
Subject: [PATCHv2 03/10] rfkill: Point to the correct deprecated doc location
Date: Mon, 22 Feb 2016 11:36:34 -0500
Message-ID: <1456159001-20307-4-git-send-email-jprvita@endlessm.com>
References: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux@endlessm.com,
	=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?= <jprvita@endlessm.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The "claim" sysfs interface has been removed, so its documentation now
lives in the "removed" folder.

Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@endlessm.com>
---
 Documentation/ABI/stable/sysfs-class-rfkill | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/Documentation/ABI/stable/sysfs-class-rfkill b/Documentatio=
n/ABI/stable/sysfs-class-rfkill
index 097f522..e51571e 100644
--- a/Documentation/ABI/stable/sysfs-class-rfkill
+++ b/Documentation/ABI/stable/sysfs-class-rfkill
@@ -2,8 +2,10 @@ rfkill - radio frequency (RF) connector kill switch su=
pport
=20
 For details to this subsystem look at Documentation/rfkill.txt.
=20
-For the deprecated /sys/class/rfkill/*/state and
-/sys/class/rfkill/*/claim knobs of this interface look in
+For the deprecated /sys/class/rfkill/*/claim knobs of this interface l=
ook in
+Documentation/ABI/removed/sysfs-class-rfkill.
+
+For the deprecated /sys/class/rfkill/*/state knobs of this interface l=
ook in
 Documentation/ABI/obsolete/sysfs-class-rfkill.
=20
 What: 		/sys/class/rfkill
--=20
2.5.0
