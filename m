From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] pci_get_slot()
Date: Thu, 29 Jan 2004 14:46:02 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040129224602.GB9906@kroah.com>
References: <20031015183213.GG16535@parcelfarce.linux.theplanet.co.uk> <20031218002444.GI6258@kroah.com> <20031218200031.GK15674@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>,
        linux-pci@atrey.karlin.mff.cuni.cz, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthew Wilcox <willy@debian.org>
Content-Disposition: inline
In-Reply-To: <20031218200031.GK15674@parcelfarce.linux.theplanet.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Dec 18, 2003 at 08:00:31PM +0000, Matthew Wilcox wrote:
> On Wed, Dec 17, 2003 at 04:24:44PM -0800, Greg KH wrote:
> > I've applied the pci portions of this patch to my trees and will send it
> > on after 2.6.0 is out.
> 
> James Bottomley found a bug in it; could you also apply:

Thanks, I've applied this too.

greg k-h
