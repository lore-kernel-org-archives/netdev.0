From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFT] sky2: backport patch
Date: Tue, 7 Aug 2007 17:47:41 -0400
Message-ID: <20070807174741.3972b52f@oldman>
References: <Pine.LNX.4.64.0708072043340.16599@bizon.gios.gov.pl>
	<20070807185631.GA19140@kroah.com>
	<20070807171415.6892a070@oldman>
	<46B8E53F.70605@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: Greg KH <greg@kroah.com>, Krzysztof Oledzki <olel@ans.pl>,
	netdev@vger.kernel.org, stable@kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49432 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S967072AbXHGVri convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 17:47:38 -0400
In-Reply-To: <46B8E53F.70605@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 07 Aug 2007 17:33:51 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> Stephen Hemminger wrote:
> > Any volunteers to test this, it has a backport for the three main stability patches:
> >  1. carrier management
> >  2. lost irq timer
> >  3. rechecking for packets in poll
> >  4. overlength packet hang.
> > 
> > I am away from any sky2 hardware for another week, but others maybe
> > able to validate this.
> 
> Backport to what?  from what?
>From 2.6.23-rc2 to 2.6.22.y base

> You supplied no kernel version info.
> 
> 	Jeff
> 
> 
> 
