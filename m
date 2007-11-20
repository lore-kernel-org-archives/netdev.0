From: Joe Perches <joe@perches.com>
Subject: [PATCH 50/59] net/bridge: Add missing "space"
Date: Mon, 19 Nov 2007 17:53:37 -0800
Message-ID: <9a9f50d85954bdc384d07e363cc586161a37f93b.1195454436.git.joe__39373.4363875867$1195523719$gmane$org@perches.com>
References: 1234567
 <1195523627-15389-1-git-send-email-joe@perches.com>
 <1195523627-15389-2-git-send-email-joe@perches.com>
 <1195523627-15389-3-git-send-email-joe@perches.com>
 <1195523627-15389-4-git-send-email-joe@perches.com>
 <1195523627-15389-5-git-send-email-joe@perches.com>
 <1195523627-15389-6-git-send-email-joe@perches.com>
 <1195523627-15389-7-git-send-email-joe@perches.com>
Cc: Bart De Schuymer <bart.de.schuymer@pandora.be>,
	Networking Team <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>, coreteam@netfilter.org,
	ebtables-devel@lists.sourceforge.net,
	ebtables-user@lists.sourceforge.net,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1195523627-15389-7-git-send-email-joe@perches.com>
Message-Id: <9a9f50d85954bdc384d07e363cc586161a37f93b.1195454436.git.joe@perches.com>
In-Reply-To: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
References: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 net/bridge/netfilter/ebt_among.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/netfilter/ebt_among.c b/net/bridge/netfilter/ebt_among.c
index 392d877..6436d30 100644
--- a/net/bridge/netfilter/ebt_among.c
+++ b/net/bridge/netfilter/ebt_among.c
@@ -187,7 +187,7 @@ static int ebt_among_check(const char *tablename, unsigned int hookmask,
 
 	if (datalen != EBT_ALIGN(expected_length)) {
 		printk(KERN_WARNING
-		       "ebtables: among: wrong size: %d"
+		       "ebtables: among: wrong size: %d "
 		       "against expected %d, rounded to %Zd\n",
 		       datalen, expected_length,
 		       EBT_ALIGN(expected_length));
-- 
1.5.3.5.652.gf192c

