From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [0/8] orinoco driver updates
Date: Thu, 10 Feb 2005 13:53:33 +1100
Message-ID: <20050210025333.GE5324@localhost.localdomain>
References: <20050112052352.GA30426@localhost.localdomain> <4200316F.7030401@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: orinoco-devel@lists.sourceforge.net, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4200316F.7030401@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 01, 2005 at 08:48:31PM -0500, Jeff Garzik wrote:
> David Gibson wrote:
> >Following are a bunch of patches which make a few more steps towards
> >the long overdue merge of the CVS orinoco driver into mainline.  These
> >do make behavioural changes to the driver, but they should all be
> >trivial and largely cosmetic.
> 
> OK, the changes look good, but I was waiting for the previous stuff you 
> submitted to land in upstream.
> 
> Could I convince you to rediff and resend against the latest 2.6.x snapshot?
> 
> At the time you sent these, they conflicted with a previous cleanup you 
> had sent, and that I had applied.

Ok, I'm a little confused.  The last batch were all checked against
the then-current netdev-2.6 bk tree, or was the conflict with
something you'd applied between when I pulled the tree and you looked
at the patches?  As far as I can tell all the previous batch of
patches I sent you are in netdev (plus a couple from this batch), but
most are still not in upstream.

I'm now not entirely clear on whether you want patches against the
netdev bk, or against Linus bk/snapshots.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist.  NOT _the_ _other_ _way_
				| _around_!
http://www.ozlabs.org/people/dgibson
