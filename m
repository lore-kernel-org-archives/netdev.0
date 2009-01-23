From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 1/6] Phonet: move to Networking options like other protocol stacks
Date: Fri, 23 Jan 2009 15:00:25 +0200
Message-ID: <1232715630-24951-1-git-send-email-remi.denis-courmont@nokia.com>
References: <200901231459.29743.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:37609 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755333AbZAWNAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 08:00:22 -0500
Received: from vaebh106.NOE.Nokia.com (vaebh106.europe.nokia.com [10.160.244.32])
	by mgw-mx09.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id n0NCxjJP017684
	for <netdev@vger.kernel.org>; Fri, 23 Jan 2009 07:00:20 -0600
Received: from localhost.localdomain (esdhcp041160.research.nokia.com [172.21.41.160])
	by mgw-int01.ntc.nokia.com (Switch-3.2.5/Switch-3.2.5) with ESMTP id n0ND0Fo4027886
	for <netdev@vger.kernel.org>; Fri, 23 Jan 2009 15:00:15 +0200
In-Reply-To: <200901231459.29743.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/Kconfig b/net/Kconfig
index bf27760..4640c3b 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -193,6 +193,7 @@ source "net/x25/Kconfig"
 source "net/lapb/Kconfig"
 source "net/econet/Kconfig"
 source "net/wanrouter/Kconfig"
+source "net/phonet/Kconfig"
 source "net/sched/Kconfig"
 source "net/dcb/Kconfig"
=20
@@ -237,7 +238,6 @@ source "net/can/Kconfig"
 source "net/irda/Kconfig"
 source "net/bluetooth/Kconfig"
 source "net/rxrpc/Kconfig"
-source "net/phonet/Kconfig"
=20
 config FIB_RULES
 	bool
--=20
1.5.6.3

