From: David Miller <davem@davemloft.net>
Subject: Re: READ ME, net-2.6 fully merged
Date: Fri, 18 Jul 2008 14:16:59 -0700 (PDT)
Message-ID: <20080718.141659.137928825.davem@davemloft.net>
References: <20080718.033947.193705552.davem@davemloft.net>
	<20080718165128.GC10471@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37105
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753738AbYGRVQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 17:16:59 -0400
In-Reply-To: <20080718165128.GC10471@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 18 Jul 2008 17:51:28 +0100

> David Miller wrote:
> > 
> > I merged Linus's current tree into net-next-2.6, fixed up all
> > the merge conflicts, and pushed this out as plain "net-2.6":
> > 
> > 	master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git
> 
> When I attempted to boot this on a test machine I got the following oops:

Jeff Kirsher's patch I added should have cured this.

Actually it won't, he fixed e1000ebut not e1000.

Jeff?
