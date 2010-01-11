From: Joe Perches <joe@perches.com>
Subject: [PATCH] MAINTAINERS: netfilter - Remove netfilter and
 netfilter-core lists
Date: Mon, 11 Jan 2010 03:09:43 -0800
Message-ID: <1263208183.1907.50.camel@Joe-Laptop.home>
References: <cover.1262726222.git.joe@perches.com>
	 <bccf36219f3ea5a9b7565734bc87095bc986dbe0.1262726222.git.joe@perches.com>
	 <1262805798.1952.105.camel@Joe-Laptop.home>  <4B4B02BE.5060209@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B4B02BE.5060209@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-01-11 at 11:51 +0100, Patrick McHardy wrote:
> it's enough to CC netfilter-devel and optionally
> netdev on patches, netfilter and netfilter-core are unnecessary.

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 745643b..860d04f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3742,8 +3742,6 @@ P:	Harald Welte
 P:	Jozsef Kadlecsik
 M:	Patrick McHardy <kaber@trash.net>
 L:	netfilter-devel@vger.kernel.org
-L:	netfilter@vger.kernel.org
-L:	coreteam@netfilter.org
 W:	http://www.netfilter.org/
 W:	http://www.iptables.org/
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git




