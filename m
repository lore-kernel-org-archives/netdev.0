From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH v2] MAINTAINERS: update DMFE and wireless drivers
 mailing list
Date: Thu, 8 Feb 2007 08:41:43 -0800
Message-ID: <20070208084143.96dc8811.randy.dunlap@oracle.com>
References: <20070207155236.72f0b18c.randy.dunlap@oracle.com>
	<45CAE8A5.9070703@ringis.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, linville@tuxdriver.com,
	tori@unhappy.mine.nu, jgarzik <jgarzik@pobox.com>,
	davem@davemloft.net, akpm <akpm@osdl.org>
To: Tobias =?ISO-8859-1?Q?Ringstr=F6m?= <tobias@ringis.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:26813 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423207AbXBHQvH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 11:51:07 -0500
In-Reply-To: <45CAE8A5.9070703@ringis.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 08 Feb 2007 10:08:53 +0100 Tobias Ringstr=F6m wrote:

> While editing that section, would you please remove me (Tobias=20
> Ringstrom, tori@unhappy.mine.nu) from the dmfe driver in the MAINTAIN=
ERS=20
> file. I've not followed development for ages.

OK, here's a new version of the patch.
---

=46rom: Randy Dunlap <randy.dunlap@oracle.com>

List netdev as the mailing list for DMFE (network driver)
instead of lkml.

List linux-wireless as the mailing list for wireless network drivers.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 MAINTAINERS |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

--- linux-2620-work.orig/MAINTAINERS
+++ linux-2620-work/MAINTAINERS
@@ -1094,10 +1094,8 @@ T:	git kernel.org:/pub/scm/linux/kernel/
 S:	Supported
=20
 DAVICOM FAST ETHERNET (DMFE) NETWORK DRIVER
-P:	Tobias Ringstrom
-M:	tori@unhappy.mine.nu
-L:	linux-kernel@vger.kernel.org
-S:	Maintained
+L:	netdev@vger.kernel.org
+S:	Orphan
=20
 DOCBOOK FOR DOCUMENTATION
 P:	Randy Dunlap
@@ -2343,7 +2341,7 @@ S:	Maintained
 NETWORKING [WIRELESS]
 P:	John W. Linville
 M:	linville@tuxdriver.com
-L:	netdev@vger.kernel.org
+L:	linux-wireless@vger.kernel.org
 T:	git kernel.org:/pub/scm/linux/kernel/git/linville/wireless-2.6.git
 S:	Maintained
=20
