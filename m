From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] dsa driver updates
Date: Sat, 21 Mar 2009 19:09:19 -0700 (PDT)
Message-ID: <20090321.190919.22846198.davem@davemloft.net>
References: <20090320194924.GT4738@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gary@mlbassoc.com, hawk@diku.dk
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59963
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752620AbZCVCJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 22:09:32 -0400
In-Reply-To: <20090320194924.GT4738@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Fri, 20 Mar 2009 20:49:25 +0100

> The biggest change here is the support for cascaded DSA switch chips
> (patch 3/3), which we got working.  The patch ended up rather big,
> but since all of the changes are interdependent, it was somewhat tricky
> to split it up into smaller pieces and I decided against it.
> 
> Note that patch #3 changes the DSA platform driver API to accommodate
> multiple switch chips.  It updates the current in-tree users (under
> arch/arm) accordingly.

All applied, thanks Lennert.
