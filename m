From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] remove dead skb_iter* functions
Date: Mon, 1 Nov 2004 22:54:23 +0100
Message-ID: <20041101215423.GA17080@lst.de>
References: <41868333.7050602@trash.net> <Xine.LNX.4.44.0411011502000.5409-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0411011502000.5409-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 01, 2004 at 03:03:01PM -0500, James Morris wrote:
> On Mon, 1 Nov 2004, Patrick McHardy wrote:
> 
> > Harald is working on code for pattern-matching inside
> > non-linear skbs for conntrack helpers. This code needs
> > the skb_iter* functions.
> 
> Perhaps put it back when the pattern matching code is submitted upstream.

And especially put it into some netfilter module instead of bloating
the kernel.
