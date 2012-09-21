From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH 1/3 V2] phy/micrel: Implement support for KSZ8021
Date: Fri, 21 Sep 2012 21:06:52 +0200
Message-ID: <201209212106.53069.marex@denx.de>
References: <201209212033.12738.marex@denx.de> <201209212050.46319.marex@denx.de> <20120921.145405.646315503417542108.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.choi@micrel.com,
	nobuhiro.iwamatsu.yj@renesas.com, fabio.estevam@freescale.com,
	shawn.guo@linaro.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:45808 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756608Ab2IUTGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 15:06:55 -0400
In-Reply-To: <20120921.145405.646315503417542108.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David Miller,

> From: Marek Vasut <marex@denx.de>
> Date: Fri, 21 Sep 2012 20:50:46 +0200
> 
> > Dear David Miller,
> > 
> >> From: Marek Vasut <marex@denx.de>
> >> Date: Fri, 21 Sep 2012 20:33:12 +0200
> >> 
> >> > I don't like it.
> >> 
> >> Then I'm not applying your patches.
> > 
> > What about the other part of my offer ?
> 
> I read it, and if it were relevant to this discussion I would
> have quoted it.
> 
> Can you please just fix up your patches exactly how I have asked you
> to so that I can get these bug fixes into the 'net' tree?

Sure, as you wish.

> This is completely rediculous, nobody else pushes back when I make
> simple coding style correction requests for their changes like you
> are.

You know, youth and all ... I was under the impression the patches shall be 
checkpatch clean. But you got me there quite well, something must be wrong with 
my precommit hook.

> You're behavior is self defeating, it's causing your work to not be
> useful and to not propagate to the very place where people can benefit
> from it the most.

Hey, this hurt. Anyway, about the checkpatch cleanup of the file, will that be 
welcome (afterwards I fix the patchset and repost)? Now that you pointed out 
there's more trouble in the file that is.

Best regards,
Marek Vasut
