From: David Schweikert <david@schweikert.ch>
Subject: niu: ethtool -s support -> implementation by contractor
Date: Mon, 15 Dec 2008 17:12:15 +0100
Message-ID: <20081215161215.GD26374@schweikert.ch>
References: <20081125133530.GA1633@schweikert.ch> <20081125.133124.74121407.davem@davemloft.net> <20081126095021.GB20045@schweikert.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nigel.schweikert.ch ([88.198.52.145]:49205 "EHLO
	mail.schweikert.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752397AbYLOQMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 11:12:20 -0500
Content-Disposition: inline
In-Reply-To: <20081126095021.GB20045@schweikert.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 26, 2008 at 10:50:21 +0100, David Schweikert wrote:
> On Tue, Nov 25, 2008 at 13:31:24 -0800, David Miller wrote:
> > > It is apparently not possible to set the link parameters on a niu
> > > interface (speed, duplex mode, auto-negotiation) with ethtool.
> > > Is support for it planned?
> > 
> > Yes, at some point, although that work is pretty low priority
> > to be honest.
> 
> OK, thanks for the information. Would it be possible for the company I
> work for, to somehow sponsor the development of this feature? Do you
> know maybe a fellow developer that might be interested?

We have found a company developing kernel drivers wanting to implement
this for us. Please let me know if you foresee any problem with that.

Should anything in particular be done in order for the future patch
to have good chances of being integrated in the main branch?

Cheers
David
