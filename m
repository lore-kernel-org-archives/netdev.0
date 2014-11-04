From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] cipso: kerneldoc warning fix
Date: Tue,  4 Nov 2014 20:10:01 +0100
Message-ID: <1415128201-8246-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipv4/cipso_ipv4.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 4715f25..e24df5a 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -539,7 +539,7 @@ doi_add_return:
 
 /**
  * cipso_v4_doi_free - Frees a DOI definition
- * @entry: the entry's RCU field
+ * @doi_def: the DOI definition
  *
  * Description:
  * This function frees all of the memory associated with a DOI definition.
-- 
1.9.3
