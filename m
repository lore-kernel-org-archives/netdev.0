From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] kill acient compat cruft from acenic
Date: Fri, 27 Feb 2004 21:57:29 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040227205729.GB20398@lst.de>
References: <20040227202510.GA19947@lst.de> <403FAECD.3090203@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jes@wildopensource.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <403FAECD.3090203@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Feb 27, 2004 at 03:55:41PM -0500, Jeff Garzik wrote:
> Christoph Hellwig wrote:
> >Kills lots of really old cruft and adds a little cruft to actually
> >make the driver work with recent 2.4 again.
> 
> 
> Since kcompat (http://sf.net/projects/gkernel/) lets PCI API drivers 
> work in 2.2, 2.4 and 2.6, I am OK with applying this patch...... 
> assuming there is a second patch coming to convert to pci_driver API.

Jes said he doesn't care for 2.2 and early 2.4 anymore which makes life
much easier without external compat cruft.

As soon as this patch is in Linus' tree I'll send you a followup.
