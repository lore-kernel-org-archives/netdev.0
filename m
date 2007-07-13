From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: TCP stalls in current git, possibly splice related
Date: Fri, 13 Jul 2007 07:36:49 +0200
Message-ID: <20070713053648.GX4587@kernel.dk>
References: <Line.LNX.4.64.0707121608100.10773@d.namei> <20070712.135254.112289065.davem@davemloft.net> <Line.LNX.4.64.0707122225470.13816@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:10133 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751738AbXGMFhB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2007 01:37:01 -0400
Content-Disposition: inline
In-Reply-To: <Line.LNX.4.64.0707122225470.13816@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 12 2007, James Morris wrote:
> On Thu, 12 Jul 2007, David Miller wrote:
> 
> > From: James Morris <jmorris@namei.org>
> > Date: Thu, 12 Jul 2007 16:12:25 -0400 (EDT)
> > 
> > > I'm seeing TCP connection stalls with current git, and a bisect found the 
> > > following as a possible cause:
> > 
> > To add to this James is seeing this with distcc I believe.
> 
> Correct.

I'll try and reproduce.

-- 
Jens Axboe

