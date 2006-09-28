From: David Miller <davem@davemloft.net>
Subject: Re: Bluetooth update for 2.6
Date: Thu, 28 Sep 2006 15:30:00 -0700 (PDT)
Message-ID: <20060928.153000.102908203.davem@davemloft.net>
References: <1159267581.1235.10.camel@localhost>
	<20060927.225817.106770711.davem@davemloft.net>
	<1159478084.21120.75.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:8067
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161340AbWI1W36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 18:29:58 -0400
To: marcel@holtmann.org
In-Reply-To: <1159478084.21120.75.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann <marcel@holtmann.org>
Date: Thu, 28 Sep 2006 23:14:44 +0200

> > > > here are the pending patches that didn't make it into the 2.6.18 kernel
> > > > release. I have some additional fixes, but all of them need some more
> > > > additional testing from my side.
> > > 
> > > it seems that you haven't pulled in these changes so far. So I didn't
> > > rebase the tree and simply pushed some additional ones on top of it. All
> > > three of them address the issues we had with non-blocking connects.
> > 
> > I applied all of your fixes into my tree, sorry for taking so long.
> 
> no big problem. If you haven't synced with Linus yet, then I have two
> small additional fixes that should go in with the others.

I've applied these 2 changes as patches to my tree, thanks a lot.
