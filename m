From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] driver core: Suppress sysfs warnings for
	device_rename().
Date: Tue, 20 May 2008 15:52:44 -0700
Message-ID: <20080520225244.GG15912@kroah.com>
References: <20080515095246.3b6a0d1d@gondolin.boeblingen.de.ibm.com> <20080515.010139.219194657.davem@davemloft.net> <20080515113131.2cea2bce@gondolin.boeblingen.de.ibm.com> <20080515.030054.247673168.davem@davemloft.net> <20080515120619.6c867bfb@gondolin.boeblingen.de.ibm.com> <20080520125913.777ed67d@gondolin.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	fubar@us.ibm.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Cornelia Huck <cornelia.huck@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:50562 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934179AbYETWxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 18:53:50 -0400
Content-Disposition: inline
In-Reply-To: <20080520125913.777ed67d@gondolin.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 20, 2008 at 12:59:13PM +0200, Cornelia Huck wrote:
> OK, here is an actually-compiled patch with proper description and
> s-o-b. Comments?

Looks good to me, feel free to add an:
	Acked-by: Greg Kroah-Hartman <gregkh@suse.de>

to it.

David, are you going to take this through your tree?

thanks,

greg k-h
