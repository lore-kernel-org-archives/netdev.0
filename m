From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fsl/fman: remove dTSEC-A003 Errata workaround
Date: Thu, 03 Mar 2016 15:20:56 -0500 (EST)
Message-ID: <20160303.152056.421883303011379030.davem@davemloft.net>
References: <1456696781-32384-1-git-send-email-igal.liberman@freescale.com>
	<DB5PR0401MB19282E4987BDCEBBBF7EBCC591BA0@DB5PR0401MB1928.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: igal.liberman@freescale.com, netdev@vger.kernel.org,
	scottwood@freescale.com, madalin.bucur@freescale.com
To: scott.wood@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46974 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893AbcCCUU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 15:20:58 -0500
In-Reply-To: <DB5PR0401MB19282E4987BDCEBBBF7EBCC591BA0@DB5PR0401MB1928.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Wood <scott.wood@nxp.com>
Date: Mon, 29 Feb 2016 23:30:59 +0000

> On 02/29/2016 09:17 AM, igal.liberman@freescale.com wrote:
>> From: Igal Liberman <igal.liberman@freescale.com>
>> 
>> Errata dTSEC-A003 was fixed in P4080 rev 3.0.
>> Prior revisions are not supported, so the workaround can be removed.
>> 
>> Signed-off-by: Igal Liberman <igal.liberman@freescale.com>
> 
> Since when do we not support p4080 rev 2?

Yeah, this is rediculous.  I'm not applying this patch, sorry.
