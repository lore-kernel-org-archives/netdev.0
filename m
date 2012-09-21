From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3 V2] phy/micrel: Implement support for KSZ8021
Date: Fri, 21 Sep 2012 14:10:37 -0400 (EDT)
Message-ID: <20120921.141037.1710579690343556147.davem@davemloft.net>
References: <1348195976-31703-1-git-send-email-marex@denx.de>
	<20120921.134215.1719885507288305623.davem@davemloft.net>
	<201209212004.10148.marex@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.choi@micrel.com,
	nobuhiro.iwamatsu.yj@renesas.com, fabio.estevam@freescale.com,
	shawn.guo@linaro.org
To: marex@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51226 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757358Ab2IUSKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 14:10:40 -0400
In-Reply-To: <201209212004.10148.marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Vasut <marex@denx.de>
Date: Fri, 21 Sep 2012 20:04:09 +0200

>> Rather, the goal is to properly line up function arguments with
>> the first column after the openning parenthesis on the previous
>> line.  Using TAB and SPACE characters, as needed.
>> 
>> > +	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
>> > +				| SUPPORTED_Asym_Pause),
>> 
>> This is similarly not styled properly.
> 
> This is copy-pasted from other entry. I'd hate to reformat the whole file.

I'm not asking you to, just the new code you're adding.
