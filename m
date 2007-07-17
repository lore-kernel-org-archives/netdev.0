From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 37/44] xen: add virtual network device driver
Date: Mon, 16 Jul 2007 21:07:10 -0400
Message-ID: <469C163E.40905@garzik.org>
References: <20070716231536.937393000@xensource.com>> <20070716232916.472694000@xensource.com>>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.com>,
	Andi Kleen <ak@suse.de>,
	Andrew Morton <akpm@linux-foundation.com>,
	lkml <linux-kernel@vger.kernel.org>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Xen-devel <xen-devel@lists.xensource.com>,
	Chris Wright <chrisw@sous-sol.org>,
	Ian Pratt <ian.pratt@xensource.com>,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Keir Fraser <Keir.Fraser@cl.cam.ac.uk>, netdev@vger.kernel.org
To: Jeremy Fitzhardinge <jeremy@xensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38730 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752752AbXGQBHT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 21:07:19 -0400
In-Reply-To: <20070716232916.472694000@xensource.com>>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeremy Fitzhardinge wrote:
> The network device frontend driver allows the kernel to access network
> devices exported exported by a virtual machine containing a physical
> network device driver.
> 
> 
> 
> Signed-off-by: Jeremy Fitzhardinge <jeremy@xensource.com>
> Signed-off-by: Chris Wright <chrisw@sous-sol.org>
> Cc: Ian Pratt <ian.pratt@xensource.com>
> Cc: Christian Limpach <Christian.Limpach@cl.cam.ac.uk>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Stephen Hemminger <shemminger@linux-foundation.org>
> Cc: Christoph Hellwig <hch@infradead.org>
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
> Cc: netdev@vger.kernel.org

Seems fairly reasonable.  ACK, presuming Xen dependencies are also merged.

	Jeff



