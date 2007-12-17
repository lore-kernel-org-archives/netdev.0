From: Joe Perches <joe@perches.com>
Subject: [PATCH] net/netfilter/: Spelling fixes
Date: Mon, 17 Dec 2007 11:40:34 -0800
Message-ID: <5703e57f925f31fc0eb38873bd7f10fc44f99cb4.1197918894.git.joe__33740.8521365889$1197920689$gmane$org@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>, coreteam@netfilter.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Message-Id: <5703e57f925f31fc0eb38873bd7f10fc44f99cb4.1197918894.git.joe@perches.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 net/netfilter/nf_conntrack_sip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 8f8b5a4..515abff 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -187,7 +187,7 @@ static const struct sip_header_nfo ct_sip_hdrs[] = {
 	}
 };
 
-/* get line lenght until first CR or LF seen. */
+/* get line length until first CR or LF seen. */
 int ct_sip_lnlen(const char *line, const char *limit)
 {
 	const char *k = line;
@@ -236,7 +236,7 @@ static int digits_len(struct nf_conn *ct, const char *dptr,
 	return len;
 }
 
-/* get digits lenght, skiping blank spaces. */
+/* get digits length, skipping blank spaces. */
 static int skp_digits_len(struct nf_conn *ct, const char *dptr,
 			  const char *limit, int *shift)
 {
-- 
1.5.3.7.949.g2221a6

