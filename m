From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] convert skge to pci_driver API (2nd try)
Date: Fri, 23 Jul 2004 15:22:29 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040723142229.GA30611@infradead.org>
References: <20040620112859.GA13794@lst.de> <4100F51C.3030709@syskonnect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, netdev@oss.sgi.com,
        Ralph Roesler <rroesler@syskonnect.de>,
        Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Mirko Lindner <mlindner@syskonnect.de>
Content-Disposition: inline
In-Reply-To: <4100F51C.3030709@syskonnect.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 23, 2004 at 01:23:08PM +0200, Mirko Lindner wrote:
> (http://www.syskonnect.de/syskonnect/support/driver/htm/sk9e21_lin.htm) 
> and we are busy with additional stability and robustness tests. As soon 
> as the driver is ready for the kernel stability we'll send the patches 
> to Jeff and the KML.
> 
> Therefore we would like to keep our driver consistent and it's not 
> possible for us to merge your changes into our code tree. Please don't 
> apply the patch to the kernel tree, there are several problems with proc 

Submitting big blobs is not how linux kernel development works.  Please submit
your encehancements in small, splitup patches ontop of mine that are in Jeff's
netdev queue already.
