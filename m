From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 1/1] net: fec: Fix RMON registers on imx6
Date: Tue, 02 Jul 2013 12:41:07 -0700 (PDT)
Message-ID: <20130702.124107.746381189773139461.davem@davemloft.net>
References: <Jim_Baxter_<jim_baxter@mentor.com>
	<1372674719-6525-1-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fabio.estevam@freescale.com, Frank.Li@freescale.com,
	B38611@freescale.com, joe@perches.com, cphealy@gmail.com,
	netdev@vger.kernel.org
To: jim_baxter@mentor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53215 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755143Ab3GBTlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 15:41:08 -0400
In-Reply-To: <1372674719-6525-1-git-send-email-jim_baxter@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Baxter <jim_baxter@mentor.com>
Date: Mon,  1 Jul 2013 11:31:59 +0100

> commit 38ae92d "fec: Add support for reading
> RMON registers" causes the imx6Q to crash.
> 
> This fixes it by only enabling the RMON registers, the
> registers are already cleared by the MAC being reset.
> 
> Signed-off-by: Jim Baxter <jim_baxter@mentor.com>

Applied, thanks.
