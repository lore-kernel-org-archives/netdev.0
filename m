From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [Xen-devel] xen-netback stable backports request (regression
 fixes)
Date: Wed, 5 Jun 2013 22:10:55 +0100
Message-ID: <1370466655.6652.16.camel@hastur.hellion.org.uk>
References: <1369734465.3469.52.camel@zakaz.uk.xensource.com>
	 <20130605045532.GA10475@kroah.com>
	 <1370422590.24512.135.camel@zakaz.uk.xensource.com>
	 <20130605202502.GD13713@kroah.com>
	 <1370465579.6652.14.camel@hastur.hellion.org.uk>
	 <20130605210807.GA15455@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Wei Liu <wei.liu2@citrix.com>,
	"David S. Miller" <davem@davemloft.net>, <stable@vger.kernel.org>,
	xen-devel <xen-devel@lists.xen.org>
To: Greg KH <greg@kroah.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20130605210807.GA15455@kroah.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-06-05 at 14:08 -0700, Greg KH wrote:
> On Wed, Jun 05, 2013 at 09:52:59PM +0100, Ian Campbell wrote:
> > The module parameter was introduce after 3.9 and then renamed before
> > v3.10-rc1 happened, the original name was never part of an -rc let alone
> > an actual release.
> 
> Ah, ok, my mistake then, I'll go apply this to keep things synced up.

Thanks.

> sorry for the confusion, too many patches at once to handle in the
> short-term memory...

No problem,

Ian.
