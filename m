From: David Miller <davem@davemloft.net>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Thu, 21 Feb 2008 02:12:28 -0800 (PST)
Message-ID: <20080221.021228.09081608.davem@davemloft.net>
References: <1203587699.17534.135.camel@johannes.berg>
	<20080221.020343.190715910.davem@davemloft.net>
	<1203588498.20345.20.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, joe@perches.com, netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60020
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756108AbYBUKLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 05:11:51 -0500
In-Reply-To: <1203588498.20345.20.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Thu, 21 Feb 2008 02:08:18 -0800

> Really, that should have read:
> 
> Sparse warning introduced since -rc2:
> ..etc
> 
> Harvey's best guess is this commit...

I think the commit you originally blamed got added in 2.6.24,
so it would be very difficult for it to cause a post-2.6.25-rc2
regression :-)

