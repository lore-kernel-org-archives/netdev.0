From: Greg KH <greg@kroah.com>
Subject: Re: linux-next: manual merge of the staging-next tree with the net
	tree
Date: Wed, 5 May 2010 23:21:29 -0700
Message-ID: <20100506062129.GA23076@kroah.com>
References: <20100506140543.d6f3841f.sfr@canb.auug.org.au> <20100506042048.GA25425@kroah.com> <20100506142139.c1b1c1c3.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Prashant P. Shah" <pshah.mumbai@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100506142139.c1b1c1c3.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 06, 2010 at 02:21:39PM +1000, Stephen Rothwell wrote:
> Hi Greg,
> 
> On Wed, 5 May 2010 21:20:48 -0700 Greg KH <greg@kroah.com> wrote:
> >
> > Thanks for doing this.  Hm, the arlan driver is scheduled to be deleted
> > in .35, so it would make things easier if I just do it now to keep these
> > kinds of merge issues from happening.  I'll queue that up tomorrow.
> 
> Ah, yes, that would be easier.  Thanks.

It is now deleted, along with 3 other drivers that were scheduled to be
deleted in .35, so you will not have any merge issues with them anymore.

thanks,

greg k-h
