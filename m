From: David Miller <davem@davemloft.net>
Subject: Re: Vlan interface nuisance
Date: Sun, 01 Mar 2009 21:28:24 -0800 (PST)
Message-ID: <20090301.212824.124808000.davem@davemloft.net>
References: <20090301204731.40ce346a@nehalam>
	<20090301.205702.81302378.davem@davemloft.net>
	<20090301210541.4585c199@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51156
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750730AbZCBF2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 00:28:42 -0500
In-Reply-To: <20090301210541.4585c199@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sun, 1 Mar 2009 21:05:41 -0800

> On Sun, 01 Mar 2009 20:57:02 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Sun, 1 Mar 2009 20:47:31 -0800
> > 
> > > Why is interface created through netlink named 'vlan0' and
> > > interface created through old vconfig called 'ethX.YY'.
> > > Seems like the interface should be consistent.
> > 
> > I think the netlink scheme is saner, and the idea is to
> > transition people over to that.
> > 
> > We can't change what vconfig uses, so what Patrick decided
> > to do is pretty sane if you ask me.
> 
> This is missing:

You can just say you don't think the behavior is
intentional.... :-/

