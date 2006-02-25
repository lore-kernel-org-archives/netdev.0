From: Luiz Fernando Capitulino <lcapitulino@mandriva.com.br>
Subject: [PATCH 6/6] pktgen: Updates version.
Date: Sat, 25 Feb 2006 16:08:30 -0300
Message-ID: <20060225160830.4f690931@home.brethil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	robert.olsson@its.uu.se
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161075AbWBYTIp@vger.kernel.org>
To: davem <davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 With all the previous changes, we're at a new version now.

Signed-off-by: Luiz Capitulino <lcapitulino@mandriva.com.br>

---

 net/core/pktgen.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

32d9b9951586e505b4b8bc587f9e170612a48a4d
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 5d13626..2221b86 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -153,7 +153,7 @@
 #include <asm/div64.h>		/* do_div */
 #include <asm/timex.h>
 
-#define VERSION  "pktgen v2.64: Packet Generator for packet performance testing.\n"
+#define VERSION  "pktgen v2.65: Packet Generator for packet performance testing.\n"
 
 /* #define PG_DEBUG(a) a */
 #define PG_DEBUG(a)
-- 
1.2.1.g3397f9

-- 
Luiz Fernando N. Capitulino
