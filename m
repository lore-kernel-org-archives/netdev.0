From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Small Bluetooth fix for 2.6.27-rc6
Date: Fri, 12 Sep 2008 04:15:02 +0200
Message-ID: <1221185702.6695.4.camel@californication>
References: <1221191805.11498.14.camel@californication>
	 <20080911.190153.04577110.davem@davemloft.net>
	 <1221185492.6695.2.camel@californication>
	 <20080911.191234.248780619.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:50646 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754499AbYILCOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 22:14:30 -0400
In-Reply-To: <20080911.191234.248780619.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> > > > Please pull from
> > > > 
> > > >     git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git master
> > > 
> > > You did your work against Linus's tree, so I can't pull this,
> > > it will bring in tons of irrelevant stuff into net-2.6.
> > > 
> > > Please send me pull requests using net-2.6 as your base.
> > 
> > I re-based the tree on net-2.6 now. Please pull.
> 
> Pulled, thanks.

I assume you want me to queue the compiler warning fix for the next
merge window, right?

Regards

Marcel


