From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH] Software receive packet steering
Date: Thu, 23 Apr 2009 09:29:25 +0200
Message-ID: <20090423072925.GO4593@kernel.dk>
References: <20090422.022120.211323498.davem@davemloft.net> <Pine.LNX.4.64.0904222156300.21763@ask.diku.dk> <20090423065830.GN4593@kernel.dk> <20090423.002524.32556359.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hawk@diku.dk, therbert@google.com, shemminger@vyatta.com,
	dada1@cosmosbay.com, andi@firstfloor.org, netdev@vger.kernel.org,
	Robert.Olsson@data.slu.se, jens.laas@ITS.UU.SE, hawk@comx.dk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([93.163.65.50]:49352 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756108AbZDWH31 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2009 03:29:27 -0400
Content-Disposition: inline
In-Reply-To: <20090423.002524.32556359.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 23 2009, David Miller wrote:
> From: Jens Axboe <jens.axboe@oracle.com>
> Date: Thu, 23 Apr 2009 08:58:30 +0200
> 
> > On Wed, Apr 22 2009, Jesper Dangaard Brouer wrote:
> >> On Wed, 22 Apr 2009, David Miller wrote:
> >>
> >>> One thought I keep coming back to is the hack the block layer
> >>> is using right now.  It remembers which CPU a block I/O request
> >>> comes in on, and it makes sure the completion runs on that
> >>> cpu too.
> > 
> > Hack?! :-)
> 
> I meant hack in the most positive sense :)

Duly noted ;-)

-- 
Jens Axboe

