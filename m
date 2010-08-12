From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH staging] Add SBE 2T3E3 WAN driver
Date: Thu, 12 Aug 2010 14:23:02 -0700
Message-ID: <20100812212302.GA16729@kroah.com>
References: <m3ocdoasen.fsf@intrepid.localdomain>
 <20100731195335.GB4644@kroah.com>
 <m362zv5oet.fsf@intrepid.localdomain>
 <20100801002713.GA6751@kroah.com>
 <m3bp97tty8.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:42829 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753114Ab0HLVX6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Aug 2010 17:23:58 -0400
Content-Disposition: inline
In-Reply-To: <m3bp97tty8.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 12, 2010 at 11:14:07PM +0200, Krzysztof Halasa wrote:
> Greg,
> 
> I have added the TODO file and removed #define DRV_NAME "SBE 2T3E3".
> The include/linux/pci_ids.h chunk is now also in Linus' tree, I'm still
> not removing it from this patch to avoid dependency on the very tip.
> Tested with 2.6.35.
> 
> TIA for looking into this.
> BTW the original driver tarball is now accessible at
> http://userweb.kernel.org/~chris/SBE_2T3_Linux_2.0c.tgz

Thanks for puttting it up.

I'll queue this up in a few weeks after the 2.6.36 merge window closes
and things settle down.

greg k-h
