From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH 1/3 V2] phy/micrel: Implement support for KSZ8021
Date: Fri, 21 Sep 2012 20:33:12 +0200
Message-ID: <201209212033.12738.marex@denx.de>
References: <1348195976-31703-1-git-send-email-marex@denx.de> <201209212004.10148.marex@denx.de> <20120921.141037.1710579690343556147.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.choi@micrel.com,
	nobuhiro.iwamatsu.yj@renesas.com, fabio.estevam@freescale.com,
	shawn.guo@linaro.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:40276 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757518Ab2IUSdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 14:33:16 -0400
In-Reply-To: <20120921.141037.1710579690343556147.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David Miller,

> From: Marek Vasut <marex@denx.de>
> Date: Fri, 21 Sep 2012 20:04:09 +0200
> 
> >> Rather, the goal is to properly line up function arguments with
> >> the first column after the openning parenthesis on the previous
> >> line.  Using TAB and SPACE characters, as needed.
> >> 
> >> > +	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
> >> > +				| SUPPORTED_Asym_Pause),
> >> 
> >> This is similarly not styled properly.
> > 
> > This is copy-pasted from other entry. I'd hate to reformat the whole
> > file.
> 
> I'm not asking you to, just the new code you're adding.

I don't like it. What'd you say to me linting the whole file with checkpatch in 
a subsequent patch?

Best regards,
Marek Vasut
