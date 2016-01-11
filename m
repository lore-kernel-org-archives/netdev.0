From: Marek Vasut <marex@denx.de>
Subject: [PATCH 3/5] of: Add vendor prefix for I/F/I
Date: Mon, 11 Jan 2016 19:48:01 +0100
Message-ID: <1452538083-7331-3-git-send-email-marex@denx.de>
References: <1452538083-7331-1-git-send-email-marex@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Marek Vasut <marex@denx.de>,
	Mark Rutland <mark.rutland@arm.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:52110 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933979AbcAKSsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 13:48:19 -0500
In-Reply-To: <1452538083-7331-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add vendor prefix for I/F/I, Ingenieurb=C3=BCro F=C3=BCr IC-Technologie
http://www.ifi-pld.de/

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Oliver Hartkopp <socketcan@hartkopp.net>
Cc: Wolfgang Grandegger <wg@grandegger.com>
---
 Documentation/devicetree/bindings/vendor-prefixes.txt | 1 +
 1 file changed, 1 insertion(+)

diff --git a/Documentation/devicetree/bindings/vendor-prefixes.txt b/Do=
cumentation/devicetree/bindings/vendor-prefixes.txt
index 55df1d4..e683e61 100644
--- a/Documentation/devicetree/bindings/vendor-prefixes.txt
+++ b/Documentation/devicetree/bindings/vendor-prefixes.txt
@@ -110,6 +110,7 @@ hp	Hewlett Packard
 i2se	I2SE GmbH
 ibm	International Business Machines (IBM)
 idt	Integrated Device Technologies, Inc.
+ifi	Ingenieurburo Fur Ic-Technologie (I/F/I)
 iom	Iomega Corporation
 img	Imagination Technologies Ltd.
 ingenic	Ingenic Semiconductor
--=20
2.1.4
