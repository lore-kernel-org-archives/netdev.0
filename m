From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [SCTP] Do not interleave non-fragments when in partial
 delivery
Date: Wed, 18 Apr 2007 14:11:40 -0700 (PDT)
Message-ID: <20070418.141140.66177794.davem@davemloft.net>
References: <46266597.2000705@hp.com>
	<20070418.132408.15264893.davem@davemloft.net>
	<4626850A.2060008@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43864
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992721AbXDRVLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 17:11:37 -0400
In-Reply-To: <4626850A.2060008@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 18 Apr 2007 16:52:26 -0400

> David Miller wrote:
> > From: Vlad Yasevich <vladislav.yasevich@hp.com>
> > Date: Wed, 18 Apr 2007 14:38:15 -0400
> > 
> >> This is a bug fix, but done on top of 2.6.22 tree.  I am trying
> >> to minimize the amount of conflict this would cause during merge
> >> by doing it this way.  However, if you would rather keep all the bugfixes
> >> in net-2.6, I can do that too, but that _will_ give you conflicts.
> > 
> > I've already determined that I'm destined to deal with tons
> > of conclicts anyways :-)
> > 
> > I'll backport this to net-2.6 unless you beat me to it :-)
> 
> attached :)

Thanks a lot, applied.
