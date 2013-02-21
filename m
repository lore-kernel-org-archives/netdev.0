From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: Ensure that initialization is done prior to
 request_irq()
Date: Thu, 21 Feb 2013 15:38:12 -0500 (EST)
Message-ID: <20130221.153812.2039434956437238374.davem@davemloft.net>
References: <1361474510-14286-1-git-send-email-fabio.estevam@freescale.com>
	<20130221.152724.6508078801736235.davem@davemloft.net>
	<CAOMZO5ArHJy=KN8R5F0cOhDN=MnxRTmBUOgDsn8zutrTNw=igg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fabio.estevam@freescale.com, Frank.Li@freescale.com,
	s.hauer@pengutronix.de, jim_baxter@mentor.com,
	netdev@vger.kernel.org
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34904 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759540Ab3BUUiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 15:38:15 -0500
In-Reply-To: <CAOMZO5ArHJy=KN8R5F0cOhDN=MnxRTmBUOgDsn8zutrTNw=igg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Thu, 21 Feb 2013 17:29:46 -0300

> On Thu, Feb 21, 2013 at 5:27 PM, David Miller <davem@davemloft.net> wrote:
> 
>> Looks good, did you test this yourself or should we wait for others to
>> test it out?
> 
> Yes, I tested it myself. I was the one who reported this bug and this
> fixes the problem.

Perfect, applied to 'net', thanks!
