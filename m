From: Claudiu Manoil <claudiu.manoil@nxp.com>
Subject: RE: [PATCH] gianfar: Enable eTSEC-106 erratum w/a for MPC8548E Rev2
Date: Thu, 3 Mar 2016 09:10:16 +0000
Message-ID: <DB4PR04MB3797401A1662F2CD2FBA81C96BD0@DB4PR04MB379.eurprd04.prod.outlook.com>
References: <20160303.090751.336624849.nemoto@toshiba-tops.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Atsushi Nemoto <nemoto@toshiba-tops.co.jp>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0061.outbound.protection.outlook.com ([157.55.234.61]:53808
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756681AbcCCJZL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 04:25:11 -0500
In-Reply-To: <20160303.090751.336624849.nemoto@toshiba-tops.co.jp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Atsushi Nemoto [mailto:nemoto@toshiba-tops.co.jp]
>Sent: Thursday, March 03, 2016 2:08 AM
>To: Claudiu Manoil <claudiu.manoil@freescale.com>; netdev@vger.kernel.org
>Subject: [PATCH] gianfar: Enable eTSEC-106 erratum w/a for MPC8548E Rev2
>
>Enable workaround for MPC8548E erratum eTSEC 106,
>"Excess delays when transmitting TOE=1 large frames".
>(see commit 53fad77375ce "gianfar: Enable eTSEC-20 erratum w/a
>for P2020 Rev1")
>
>This erratum was fixed in Rev 3.1.x.
>

(Confirmed with MPC8548E Chip Errata document, rev 9. Thanks.)

Acked-by: Claudiu Manoil <claudiu.manoil@freescale.com>
