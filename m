From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [-mm patch] make tcp_splice_data_recv() static
Date: Wed, 12 Sep 2007 19:44:25 +0200
Message-ID: <20070912174424.GU25592@kernel.dk>
References: <20070831215822.26e1432b.akpm@linux-foundation.org> <20070909202558.GZ3563@stusta.de> <20070912.062102.116370922.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bunk@kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([87.55.233.238]:28206 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968606AbXILRot (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 13:44:49 -0400
Content-Disposition: inline
In-Reply-To: <20070912.062102.116370922.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 12 2007, David Miller wrote:
> From: Adrian Bunk <bunk@kernel.org>
> Date: Sun, 9 Sep 2007 22:25:58 +0200
> 
> > On Fri, Aug 31, 2007 at 09:58:22PM -0700, Andrew Morton wrote:
> > >...
> > > Changes since 2.6.23-rc3-mm1:
> > >...
> > >  git-block.patch
> > >...
> > >  git trees
> > >...
> > 
> > tcp_splice_data_recv() can become static.
> > 
> > Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> I'll let Jens or similar pick this one up since it
> obviously won't apply to my tree.

I'll shove it in my #splice-net branch, where it originates from.

-- 
Jens Axboe

