From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2.6] Intersil Prism54 wireless driver
Date: Wed, 10 Mar 2004 17:29:14 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040310172914.A25155@infradead.org>
References: <20040304023524.GA19453@bougret.hpl.hp.com> <20040310165548.A24693@infradead.org> <20040310172114.GA8867@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, prism54-devel@prism54.org,
        "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>,
        netdev@oss.sgi.com,
        Linux kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
Content-Disposition: inline
In-Reply-To: <20040310172114.GA8867@bougret.hpl.hp.com>; from jt@bougret.hpl.hp.com on Wed, Mar 10, 2004 at 09:21:14AM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 10, 2004 at 09:21:14AM -0800, Jean Tourrilhes wrote:
> > --- linux-2.6.3/drivers/net/wireless/prism54/isl_wds.c	Thu Jan  1 00:00:00 1970
> > +++ linux-2.6.3-prism54/drivers/net/wireless/prism54/isl_wds.c	Thu Mar  4 02:00:01 2004
> > 
> > 	WDS doesn't belong into a driver but in higher-level code.
> 
> 	The big 802.11 reorg can only happen when HostAP is in the
> kernel.

I don't quite understand that comment.  This feature doesn't belong into
a driver.  Whether it's some day implemented in a hypothetic 802.11 midlayer
that can only be done with another driver merged is a different question,
isn't it?

> 
> 	Regards,
> 
> 	Jean
> 
---end quoted text---
