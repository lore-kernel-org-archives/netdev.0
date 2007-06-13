From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 0/7] sky2 version 1.15 (88e8071) support
Date: Wed, 13 Jun 2007 13:37:16 -0700
Message-ID: <20070613133716.39377e85@localhost>
References: <20070605002320.868185090@linux-foundation.org>
	<46704E03.8060307@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56143 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754419AbXFMUho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 16:37:44 -0400
In-Reply-To: <46704E03.8060307@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Jun 2007 16:05:23 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> Stephen Hemminger wrote:
> > These changes are to enable the Yukon Extreme (88e8071)
> > chipset. This chip is similar to earlier chip but has a different
> > set of offloading operations and some other minor quirks.
> > 
> > Marvell has given me some evaluation boards with the 88e8071
> > chip set. The chip is available now, but haven't seen a systems
> > with the hardware yet. The support fot this is exprerimental
> > at this point, but haven't encountered any new problems.
> 
> Just to confirm... these are all for #upstream (2.6.23), correct?
> 
> 

Yes, given that the hardware is not available on common platforms yet,
it should go into 2.6.23
