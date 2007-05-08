From: olof@lixom.net (Olof Johansson)
Subject: Re: [PATCH v3] [2/10] [REAL 2/10] pasemi_mac: Move the IRQ mapping from the PCI layer to the driver
Date: Tue, 8 May 2007 00:32:36 -0500
Message-ID: <20070508053236.GA14152@lixom.net>
References: <20070428203624.GA4331@lixom.net> <20070428203650.GC4331@lixom.net> <20070428205726.GB4811@lixom.net> <4640046A.4060004@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:32960 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754675AbXEHGIo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 02:08:44 -0400
Content-Disposition: inline
In-Reply-To: <4640046A.4060004@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 08, 2007 at 01:02:34AM -0400, Jeff Garzik wrote:
> Olof Johansson wrote:
> >Fixes for ethernet IRQ mapping, to be done in the driver instead of in
> >the platform setup code.
> >
> >Signed-off-by: Olof Johansson <olof@lixom.net>
> 
> patch failed to apply, so I stopped here
> 
> ACK patches 2-7

Looks like it had some fuzz due to OF changes on powerpc, I've refreshed
and will repost all but 1/10.


Thanks,

-Olof
