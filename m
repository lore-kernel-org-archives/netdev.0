From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [patch 5/7] ep93xx: some minor cleanups to the ep93xx eth driver
Date: Tue, 26 Dec 2006 22:56:30 +0000
Message-ID: <20061226225630.GA20086@flint.arm.linux.org.uk>
References: <200612192108.kBJL8ndY010501@shell0.pdx.osdl.net> <459196FD.7000600@garzik.org> <20061226214227.GB23313@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, akpm@osdl.org,
	netdev@vger.kernel.org, burman.yan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([217.147.92.249]:4857 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932840AbWLZXyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Dec 2006 18:54:50 -0500
To: Lennert Buytenhek <buytenh@wantstofly.org>
Content-Disposition: inline
In-Reply-To: <20061226214227.GB23313@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 26, 2006 at 10:42:27PM +0100, Lennert Buytenhek wrote:
> On Tue, Dec 26, 2006 at 04:41:17PM -0500, Jeff Garzik wrote:
> 
> > >Small cleanup in the Cirrus Logic EP93xx ethernet driver: Check for NULL
> > >pointer before dereferencing it instead of after.  Remove unreferenced
> > >variable.
> > >
> > >Signed-off-by: Yan Burman <burman.yan@gmail.com>
> > >Cc: Jeff Garzik <jeff@garzik.org>
> > >Cc: Russell King <rmk@arm.linux.org.uk>
> > >Signed-off-by: Andrew Morton <akpm@osdl.org>
> 
> Why wasn't I CC'ed on this?

Probably because akpm thinks it was something to do with me... may I
suggest it might help to have an entry in MAINTAINERS?

-- 
Russell King
