From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2/2] MAINTAINERS: add entry for wireless networking
Date: Wed, 18 Jan 2006 17:44:53 -0500
Message-ID: <20060118224453.GG6583@tuxdriver.com>
References: <20060118224300.GF6583@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161033AbWARWo7@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060118224300.GF6583@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add an entry to MAINTAINERS for wireless networking, just so people
know whom to bless with patches.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 MAINTAINERS |    7 +++++++
 1 files changed, 7 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 6d1b048..23aca6f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1844,6 +1844,13 @@ L:	netdev@vger.kernel.org
 T:	git kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git
 S:	Maintained
 
+NETWORKING [WIRELESS]
+P:	John W. Linville
+M:	linville@tuxdriver.com
+L:	netdev@vger.kernel.org
+T:	git kernel.org:/pub/scm/linux/kernel/git/linville/wireless-2.6.git
+S:	Maintained
+
 IPVS
 P:	Wensong Zhang
 M:	wensong@linux-vs.org
-- 
John W. Linville
linville@tuxdriver.com
