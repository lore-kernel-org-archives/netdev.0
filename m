From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Thu, 21 Feb 2008 02:16:33 -0800
Message-ID: <1203588993.20345.27.camel@brick>
References: <1203587699.17534.135.camel@johannes.berg>
	 <20080221.020343.190715910.davem@davemloft.net>
	 <1203588498.20345.20.camel@brick>
	 <20080221.021228.09081608.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, joe@perches.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:8008 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754915AbYBUKQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 05:16:18 -0500
Received: by wa-out-1112.google.com with SMTP id v27so4429313wah.23
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2008 02:16:17 -0800 (PST)
In-Reply-To: <20080221.021228.09081608.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-02-21 at 02:12 -0800, David Miller wrote:
> From: Harvey Harrison <harvey.harrison@gmail.com>
> Date: Thu, 21 Feb 2008 02:08:18 -0800
> 
> > Really, that should have read:
> > 
> > Sparse warning introduced since -rc2:
> > ..etc
> > 
> > Harvey's best guess is this commit...
> 
> I think the commit you originally blamed got added in 2.6.24,
> so it would be very difficult for it to cause a post-2.6.25-rc2
> regression :-)
> 

I don't view it as a regression, just seeing if warning maintainers
incrementally when new sparse warnings get in ends up being well
received.

In addition to trying to lower the noise level of the existing
warnings, might as well try to stem the tide of new ones.

Harvey



