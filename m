From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 5/7] ep93xx: some minor cleanups to the ep93xx eth driver
Date: Tue, 26 Dec 2006 16:41:17 -0500
Message-ID: <459196FD.7000600@garzik.org>
References: <200612192108.kBJL8ndY010501@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, burman.yan@gmail.com, rmk@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41553 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932793AbWLZVlU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Dec 2006 16:41:20 -0500
To: akpm@osdl.org
In-Reply-To: <200612192108.kBJL8ndY010501@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Yan Burman <burman.yan@gmail.com>
> 
> Small cleanup in the Cirrus Logic EP93xx ethernet driver: Check for NULL
> pointer before dereferencing it instead of after.  Remove unreferenced
> variable.
> 
> Signed-off-by: Yan Burman <burman.yan@gmail.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Russell King <rmk@arm.linux.org.uk>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

applied


