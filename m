From: Karen Shaeffer <shaeffer@neuralscape.com>
Subject: Re: Gentle Guide to the Network Stack
Date: Tue, 17 Jun 2008 07:56:55 -0700
Message-ID: <20080617145655.GB16229@synapse.neuralscape.com>
References: <200806171105.23069.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Olaf Kirch <okir@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [198.144.200.82] ([198.144.200.82]:34018 "EHLO neuralscape.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757859AbYFQO5v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 10:57:51 -0400
Content-Disposition: inline
In-Reply-To: <200806171105.23069.okir@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2008 at 11:05:22AM +0200, Olaf Kirch wrote:
> Hi all,
> 
> I started putting together a paper on the Linux network stack,
> focusing on how things fit together, and help relative beginners
> understand the machinery, rather than giving a full-blown highly
> detailed cross reference (which would be outdated more quickly
> than you can re-run latex anyway :-)
> I intend to release it under the GPL or GNU FDL or similar license -
> I haven't fully made up my mind yet on what works best.
> 
> You can find the first couple of pages at
> http://oss.oracle.com/~okir/network/paper.pdf
> 
> I'd be very interested in general feedback on the approach taken,
> the level of detail and such. In case I missed the fact that
> someone else is currently doing the same, please let me know, too.
> 
> Cheers,
> Olaf

Hi Olaf,
I suggest you take a close look at O'Reilly's "Understanding
Linux Network Internals" as a jumping off point. This work
deals with IPv4 Layer 3, and L2 implementations for the 2.6
kernel. In my opinion, it is very well done. What would be a
very nice compliment is to focus on L4 protocols and
implementations and the socket API implementation within the kernel.

Thanks,
Karen


-- 
 Karen Shaeffer
 Neuralscape, Palo Alto, Ca. 94306
 shaeffer@neuralscape.com  http://www.neuralscape.com
