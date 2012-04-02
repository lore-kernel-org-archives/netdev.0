From: Andreas Mohr <andi@lisas.de>
Subject: Re: [PATCH] via-rhine: fix wait-bit inversion.
Date: Mon, 2 Apr 2012 07:43:27 +0200
Message-ID: <20120402054327.GA24473@rhlx01.hs-esslingen.de>
References: <20120401223500.GA28138@electric-eye.fr.zoreil.com>
 <20120401.231044.2143460898946854493.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org, andi@lisas.de,
	DavidLv@viatech.com.cn
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:49719 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183Ab2DBFxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 01:53:53 -0400
Content-Disposition: inline
In-Reply-To: <20120401.231044.2143460898946854493.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sun, Apr 01, 2012 at 11:10:44PM -0400, David Miller wrote:
> From: Francois Romieu <romieu@fr.zoreil.com>
> Date: Mon, 2 Apr 2012 00:35:00 +0200
> 
> > From: Andreas Mohr <andi@lisas.de>
> > 
> > Bug appeared in a384a33bb1c9ec2d99db2046b41f57023fa7d77b
> > ("via-rhine: RHINE_WAIT_FOR macro removal). It can be noticed
> > during suspend/resume.
> > 
> > Signed-off-by: Andreas Mohr <andi@lisas.de>
> > Acked-by: Francois Romieu <romieu@fr.zoreil.com>
> > Cc: David Lv <DavidLv@viatech.com.cn>
> 
> Applied and queued up for -stable, thanks.

Fully happy with all "automatisms" (Signed-off-by etc. -
I didn't bother at that time for such a minor step),
thank you for very fast/cooperative handling to all involved parties!

Side note (not mentioned yet): that fix was sufficient to get HEAD
(well, at least f2cedb63df14342) working, too.

Thanks,

Andreas Mohr
