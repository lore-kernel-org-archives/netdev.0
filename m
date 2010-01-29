From: David Miller <davem@davemloft.net>
Subject: Re: [stable] [PATCH] be2net: Bug fix to support newer generation
 of BE ASIC
Date: Thu, 28 Jan 2010 21:56:29 -0800 (PST)
Message-ID: <20100128.215629.189699027.davem@davemloft.net>
References: <20100128232829.GA31884@kroah.com>
	<1264722956.373.561.camel@localhost>
	<20100129055157.GA10427@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, greg@kroah.com, netdev@vger.kernel.org,
	stable-review@kernel.org, stable@kernel.org
To: ajitk@serverengines.com, ajitkhaparde@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49250
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750709Ab0A2F4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 00:56:18 -0500
In-Reply-To: <20100129055157.GA10427@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitkhaparde@gmail.com>
Date: Fri, 29 Jan 2010 11:21:59 +0530

> I plan rectify the error pointed by Ben and Greg and spin the patch again and
> resend it.  Please let me know if you think otherwise.

I already made the obvious memset() arg fix in my tree
as I said I would in my reply to Ben's posting.

It never makes sense to 'respin' patches I've already
applied to net-2.6, once I push it out to kernel.org
it's irreversable so you must send relative fixes.
