From: Greg KH <gregkh@suse.de>
Subject: [065/264] MAINTANERS: update Qualcomm Atheros addresses
Date: Wed, 09 Nov 2011 13:31:52 -0800
Message-ID: <20111109213148.638821009@clark.kroah.org>
References: <20111109213508.GA3476@kroah.com>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, stable@kernel.org,
	netdev@vger.kernel.org, jouni@qca.qualcomm.com,
	yangjie@qca.qualcomm.com, vthiagar@qca.qualcomm.com,
	senthilb@qca.qualcomm.com,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111109213508.GA3476@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

3.1-stable review patch.  If anyone has any objections, please let me know.

------------------

From: "Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>

commit fe8e084455f273b32cc57a5fbaf6c22ef984d657 upstream.

Qualcomm ate up Atheros, all of the old e-mail addresses
no longer work and e-mails sent to it will bounce. Update
the addresses to the new shiny Qualcomm Atheros (QCA) ones.

Cc: stable@kernel.org
Cc: netdev@vger.kernel.org
Cc: jouni@qca.qualcomm.com
Cc: yangjie@qca.qualcomm.com
Cc: vthiagar@qca.qualcomm.com
Cc: senthilb@qca.qualcomm.com
Signed-off-by: Luis R. Rodriguez <mcgrof@qca.qualcomm.com>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 MAINTAINERS |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1230,7 +1230,7 @@ F:	Documentation/aoe/
 F:	drivers/block/aoe/
 
 ATHEROS ATH GENERIC UTILITIES
-M:	"Luis R. Rodriguez" <lrodriguez@atheros.com>
+M:	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>
 L:	linux-wireless@vger.kernel.org
 S:	Supported
 F:	drivers/net/wireless/ath/*
@@ -1238,7 +1238,7 @@ F:	drivers/net/wireless/ath/*
 ATHEROS ATH5K WIRELESS DRIVER
 M:	Jiri Slaby <jirislaby@gmail.com>
 M:	Nick Kossifidis <mickflemm@gmail.com>
-M:	"Luis R. Rodriguez" <lrodriguez@atheros.com>
+M:	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>
 M:	Bob Copeland <me@bobcopeland.com>
 L:	linux-wireless@vger.kernel.org
 L:	ath5k-devel@lists.ath5k.org
@@ -1247,10 +1247,10 @@ S:	Maintained
 F:	drivers/net/wireless/ath/ath5k/
 
 ATHEROS ATH9K WIRELESS DRIVER
-M:	"Luis R. Rodriguez" <lrodriguez@atheros.com>
-M:	Jouni Malinen <jmalinen@atheros.com>
-M:	Vasanthakumar Thiagarajan <vasanth@atheros.com>
-M:	Senthil Balasubramanian <senthilkumar@atheros.com>
+M:	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>
+M:	Jouni Malinen <jouni@qca.qualcomm.com>
+M:	Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>
+M:	Senthil Balasubramanian <senthilb@qca.qualcomm.com>
 L:	linux-wireless@vger.kernel.org
 L:	ath9k-devel@lists.ath9k.org
 W:	http://wireless.kernel.org/en/users/Drivers/ath9k
