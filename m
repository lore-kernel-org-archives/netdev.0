From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8][BONDING]: Some BUGs and deadlocks fixes and a bit
 of concomitant cleanups.
Date: Fri, 02 May 2008 17:06:43 -0700 (PDT)
Message-ID: <20080502.170643.71090198.davem@davemloft.net>
References: <481735F4.30909@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54384
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760074AbYECAGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 20:06:44 -0400
In-Reply-To: <481735F4.30909@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 29 Apr 2008 18:51:32 +0400

> While looking at the bonding driver I found four bugs visible with
> the unaided eye. Here are the fixes, but I also cleaned up some
> places, I just couldn't come by. If you consider those cleanups to
> be for next merge window, just kick me and I'll resubmit this set
> without them.

I think all of these patches are excellent.

Jay, et al., can you make sure these go to Jeff and
get integrated?

Thanks.
