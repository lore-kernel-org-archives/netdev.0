From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC] introducing the Atheros L2 Fast Ethernet driver
Date: Tue, 04 Dec 2007 17:47:06 -0500
Message-ID: <4755D8EA.9060201@garzik.org>
References: <4755D39D.30005@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, synrg@debian.org
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53030 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751793AbXLDWrJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 17:47:09 -0500
In-Reply-To: <4755D39D.30005@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Snook wrote:
> Hey folks --
> 
>     I've begun cleaning up the atl2 vendor driver for merging.  It's 
> very similar to the atl1 driver, and needs a lot of the same work, 
> though I have already fixed the 64-bit DMA data corrupter that atl1 
> users remember so fondly.  Right now this is very raw, and there is a 
> large amount of cosmetic work to do to make it more maintainable, but it 
> should generally work, at least as well as the vendor driver does.
> 
>     While this is in pre-submission cleanup mode, the latest standalone 
> source tarball and patch (currently against 2.6.23) will be available here:
> 
> http://people.redhat.com/csnook/atl2/
> 
>     If you have atl2 hardware, please give this a spin.  I plan to 
> submit the driver for merging some time in the next month or so.  
> Questions, comments, patches welcome.

Why not update atl1 for this new hardware?  Why is a new driver needed?

	Jeff



