From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] be2net: Bug fix to support newer generation
 of BE ASIC
Date: Thu, 28 Jan 2010 15:28:29 -0800
Message-ID: <20100128232829.GA31884@kroah.com>
References: <20100128075633.GA4785@serverengines.com>
 <1264718429.373.520.camel@localhost>
 <20100128225114.GA1588@kroah.com>
 <1264720828.373.552.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ajit Khaparde <ajitk@serverengines.com>,
	netdev <netdev@vger.kernel.org>, stable-review@kernel.org,
	David Miller <davem@davemloft.net>, stable@kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:38786 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753203Ab0A1Xc5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jan 2010 18:32:57 -0500
Content-Disposition: inline
In-Reply-To: <1264720828.373.552.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 28, 2010 at 11:20:28PM +0000, Ben Hutchings wrote:
> On Thu, 2010-01-28 at 14:51 -0800, Greg KH wrote:
> > On Thu, Jan 28, 2010 at 10:40:29PM +0000, Ben Hutchings wrote:
> [...]
> > > Also, you should either send this patch to stable@kernel.org, or NAK the
> > > addition of PCI ids for BladeEngine 3 in 2.6.32.7.
> > 
> > Why?  How does the pci id patch for 2.6.32.7 matter with this change?
> 
> Because it looks like the devices being added won't work without this.

Hm, what is "this"?  I seem to have been lost on this thread.

Care to explain it better?  2.6.32.7 is now out with the pci ids, so if
I need to add something else for the next .32-stable kernel, please let
me know.

thanks,

greg k-h
