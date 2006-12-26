From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [patch 5/7] ep93xx: some minor cleanups to the ep93xx eth driver
Date: Tue, 26 Dec 2006 22:42:27 +0100
Message-ID: <20061226214227.GB23313@xi.wantstofly.org>
References: <200612192108.kBJL8ndY010501@shell0.pdx.osdl.net> <459196FD.7000600@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@vger.kernel.org, burman.yan@gmail.com,
	rmk@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:47786 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932817AbWLZVm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Dec 2006 16:42:29 -0500
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <459196FD.7000600@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 26, 2006 at 04:41:17PM -0500, Jeff Garzik wrote:

> >Small cleanup in the Cirrus Logic EP93xx ethernet driver: Check for NULL
> >pointer before dereferencing it instead of after.  Remove unreferenced
> >variable.
> >
> >Signed-off-by: Yan Burman <burman.yan@gmail.com>
> >Cc: Jeff Garzik <jeff@garzik.org>
> >Cc: Russell King <rmk@arm.linux.org.uk>
> >Signed-off-by: Andrew Morton <akpm@osdl.org>

Why wasn't I CC'ed on this?
