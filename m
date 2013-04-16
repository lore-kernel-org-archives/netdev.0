From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] can: mcp251x: Remove unneeded PM_OPS definitions
Date: Tue, 16 Apr 2013 15:49:31 -0400 (EDT)
Message-ID: <20130416.154931.769448863504622210.davem@davemloft.net>
References: <1366140511-3836-1-git-send-email-fabio.estevam@freescale.com>
	<516DA995.8010301@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fabio.estevam@freescale.com, netdev@vger.kernel.org,
	joe@perches.com
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49183 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935589Ab3DPTte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 15:49:34 -0400
In-Reply-To: <516DA995.8010301@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Tue, 16 Apr 2013 21:42:13 +0200

> On 04/16/2013 09:28 PM, Fabio Estevam wrote:
>> SIMPLE_DEV_PM_OPS macro can handle !CONFIG_PM_SLEEP case nicely, so there is no
>> need to define PM_OPS for both CONFIG_PM_SLEEP and !CONFIG_PM_SLEEP cases.
>> 
>> Remove the unneeded definitions.
>> 
>> Cc: Marc Kleine-Budde <mkl@pengutronix.de>
>> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
> 
> David, are you directly taking the whole series? If not, this patch will
> go through the linux-can tree.

I intend on taking it all in one gulp, thanks.
