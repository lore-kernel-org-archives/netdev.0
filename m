From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 2.6] pci.ids for e1000
Date: Tue, 30 Sep 2003 16:32:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930233251.GA21422@kroah.com>
References: <3F621965.4070106@wanadoo.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Xose Vazquez Perez <xose@wanadoo.es>
Content-Disposition: inline
In-Reply-To: <3F621965.4070106@wanadoo.es>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Sep 12, 2003 at 09:07:17PM +0200, Xose Vazquez Perez wrote:
> Jeff Garzik wrote:
> 
> > The general idea is to keep 2.4, 2.6, and pciids.sf.net in sync.
> 
> is there sync between 2.4, 2.6, and pciids.sf.net ?  ;-)
> 
> Linus and Marcelo should not accept patches against pci.ids,
> all updates should go to pciids.sf.net. And every X time
> to do a sync with 2.4 and 2.6.

I'd love to see a volunteer to try to sync these files up and routinely
send updates to the pci maintainers of the different kernel trees.

Anyone?

I also agree with David, it's completly acceptable for drivers to add
their ids to this file when they are added to the kernel tree.

thanks,

greg k-h
