From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: [PATCH RFC 1/1] usb: Tell xhci when usb data might be misaligned
Date: Mon, 3 Feb 2014 09:56:53 -0800
Message-ID: <20140203175653.GB26115@xanatos>
References: <20140130211816.GB3787@xanatos>
 <87iot1qgv6.fsf@nemi.mork.no>
 <20140130221511.GD14228@xanatos>
 <CACVXFVMVoMAH3DRiv-VYZL8VWq2Rw+fZwreVtUVm1M44HR+X8Q@mail.gmail.com>
 <20140131190035.GB18262@xanatos>
 <CACVXFVN3OsPM5CBWjc4kh_sGo3fMwpvBoYer7VtreUWrvWA=+Q@mail.gmail.com>
 <52ECF6F5.6060207@pobox.com>
 <CACVXFVOynsojKo+aukHY4q+MkEyhHXC0=OpN0ysu0TGuUjY8sA@mail.gmail.com>
 <52ED5381.2010106@pobox.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6B7707@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Mark Lord' <mlord@pobox.com>, Ming Lei <ming.lei@canonical.com>,
	=?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Dan Williams <dan.j.williams@intel.com>,
	"Nyman, Mathias" <mathias.nyman@intel.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Freddy Xin <freddy@asix.com.tw>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:15987 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752558AbaBCR4y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Feb 2014 12:56:54 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6B7707@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 03, 2014 at 09:54:09AM +0000, David Laight wrote:
> From: Mark Lord
> > On 14-02-01 09:18 AM, Ming Lei wrote:
> > >
> > > Even real regressions are easily/often introduced, and we are discussing
> > > how to fix that. I suggest to unset the flag only for the known buggy
> > > controllers.
> > 
> > It is not the controllers that are particularly "buggy" here.
> > But rather the drivers and design of parts of the kernel.
> 
> I suspect that the documentation is describing the actual implementation
> of a specific hardware implementation, not necessarily how the hardware was
> intended to behave.

You are speculating.  Please stop speculating without evidence.  It does
not add to this conversation.

Sarah Sharp
