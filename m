From: =?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
Subject: [PATCH] MAINTAINERS: Update GIT trees for network development
Date: Wed, 24 Aug 2011 11:31:42 +0200
Message-ID: <1314178302-8137-1-git-send-email-nicolas.2p.debian@free.fr>
References: <20110721.202643.1084293436022974836.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:56085 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752104Ab1HXJc3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Aug 2011 05:32:29 -0400
In-Reply-To: <20110721.202643.1084293436022974836.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove -2.6 from net and net-next tree names.

Signed-off-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
---
 MAINTAINERS |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index d32e1ca..d899040 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4442,8 +4442,8 @@ M:	"David S. Miller" <davem@davemloft.net>
 L:	netdev@vger.kernel.org
 W:	http://www.linuxfoundation.org/en/Net
 W:	http://patchwork.ozlabs.org/project/netdev/list/
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.=
6.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.gi=
t
 S:	Maintained
 F:	net/
 F:	include/net/
--=20
1.7.5.4
