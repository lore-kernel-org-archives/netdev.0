From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TUNTAP: Fix wrong debug message
Date: Mon, 24 Dec 2007 21:30:58 -0800 (PST)
Message-ID: <20071224.213058.167442659.davem@davemloft.net>
References: <200712250153.lBP1rVXR004756@dhcp-0176.miraclelinux.com>
	<1198550928.19504.1.camel@localhost>
	<20071225.122756.-713540829.tabe@miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org, maxk@qualcomm.com
To: tabe@miraclelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39355
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750784AbXLYFa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Dec 2007 00:30:59 -0500
In-Reply-To: <20071225.122756.-713540829.tabe@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toyo Abe <tabe@miraclelinux.com>
Date: Tue, 25 Dec 2007 12:27:56 +0900 (JST)

> --- Original Messsage ---
> From: Joe Perches <joe@perches.com>
> Subject: Re: [PATCH] TUNTAP: Fix wrong debug message
> Date: Mon, 24 Dec 2007 18:48:48 -0800
> Message-ID: <1198550928.19504.1.camel@localhost>
> 
> > More readable to reverse the strings
> > 
> > 		    tun->dev->name, arg ? "enabled" : "disabled");
> > 
> 
> Hello Joe,
> Thanks for your advice.
> 
> This is the more readable version.

Applied, thanks Toyo.

Joe, please don't provide patch feedback in private emails as it
appears you did here.  When you do this, it cheapens the value
of the feedback because other people reading the list cannot
benefit nor comment on it.

You've done this to me in the past too, and I told you back then
to please stop doing it.

Thanks.
