From: David Miller <davem@davemloft.net>
Subject: Re: [-mm patch] make tcp_splice_data_recv() static
Date: Wed, 12 Sep 2007 06:21:02 -0700 (PDT)
Message-ID: <20070912.062102.116370922.davem@davemloft.net>
References: <20070831215822.26e1432b.akpm@linux-foundation.org>
	<20070909202558.GZ3563@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, jens.axboe@oracle.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:54419
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757139AbXILNVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 09:21:24 -0400
In-Reply-To: <20070909202558.GZ3563@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@kernel.org>
Date: Sun, 9 Sep 2007 22:25:58 +0200

> On Fri, Aug 31, 2007 at 09:58:22PM -0700, Andrew Morton wrote:
> >...
> > Changes since 2.6.23-rc3-mm1:
> >...
> >  git-block.patch
> >...
> >  git trees
> >...
> 
> tcp_splice_data_recv() can become static.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

I'll let Jens or similar pick this one up since it
obviously won't apply to my tree.

