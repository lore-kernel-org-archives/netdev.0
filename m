From: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
Subject: [PATCH 3/3] Phonet: declare headers
Date: Wed, 24 Sep 2008 19:11:40 +0300
Message-ID: <1222272700-28232-3-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:23492 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112AbYIXQNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 12:13:23 -0400
Received: from esebh106.NOE.Nokia.com (esebh106.ntc.nokia.com [172.21.138.213])
	by mgw-mx09.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8OGD8Kn022910
	for <netdev@vger.kernel.org>; Wed, 24 Sep 2008 11:13:20 -0500
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/linux/Kbuild |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index b68ec09..f431e40 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -126,6 +126,7 @@ header-y +=3D pci_regs.h
 header-y +=3D pfkeyv2.h
 header-y +=3D pg.h
 header-y +=3D phantom.h
+header-y +=3D phonet.h
 header-y +=3D pkt_cls.h
 header-y +=3D pkt_sched.h
 header-y +=3D posix_types.h
@@ -232,6 +233,7 @@ unifdef-y +=3D if_fddi.h
 unifdef-y +=3D if_frad.h
 unifdef-y +=3D if_ltalk.h
 unifdef-y +=3D if_link.h
+unifdef-y +=3D if_phonet.h
 unifdef-y +=3D if_pppol2tp.h
 unifdef-y +=3D if_pppox.h
 unifdef-y +=3D if_tr.h
--=20
1.5.4.3

