From: Greg KH <greg@kroah.com>
Subject: Re: [09/38] xen: netfront: explicitly generate arp_notify event
 after migration.
Date: Wed, 11 Aug 2010 12:43:18 -0700
Message-ID: <20100811194318.GC23566@kroah.com>
References: <20100806183200.858950407@clark.site>
 <1281445647.24292.3897.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"stable@kernel.org" <stable@kernel.org>,
	"stable-review@kernel.org" <stable-review@kernel.org>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Ian Campbell <Ian.Campbell@eu.citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1281445647.24292.3897.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 10, 2010 at 02:07:27PM +0100, Ian Campbell wrote:
> Hi Greg,
> 
> Looks like I forgot to request this for 2.6.32 too, could you queue it
> up there as well?
> 
> It depends on the previous patch in this series (arp_notify: allow
> drivers to explicitly request a notification event.).

Now queued up for .32 and .34-stable kernels.

thanks,

greg k-h
