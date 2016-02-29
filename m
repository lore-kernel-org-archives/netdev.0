From: Scott Wood <scott.wood@nxp.com>
Subject: Re: [PATCH] fsl/fman: remove dTSEC-A003 Errata workaround
Date: Mon, 29 Feb 2016 23:30:59 +0000
Message-ID: <DB5PR0401MB19282E4987BDCEBBBF7EBCC591BA0@DB5PR0401MB1928.eurprd04.prod.outlook.com>
References: <1456696781-32384-1-git-send-email-igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "scottwood@freescale.com" <scottwood@freescale.com>,
	"madalin.bucur@freescale.com" <madalin.bucur@freescale.com>
To: "igal.liberman@freescale.com" <igal.liberman@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0066.outbound.protection.outlook.com ([157.55.234.66]:51040
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750736AbcCADGG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 22:06:06 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/29/2016 09:17 AM, igal.liberman@freescale.com wrote:
> From: Igal Liberman <igal.liberman@freescale.com>
> 
> Errata dTSEC-A003 was fixed in P4080 rev 3.0.
> Prior revisions are not supported, so the workaround can be removed.
> 
> Signed-off-by: Igal Liberman <igal.liberman@freescale.com>

Since when do we not support p4080 rev 2?

-Scott
