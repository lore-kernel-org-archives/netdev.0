From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 5/7] ep93xx: some minor cleanups to the ep93xx eth driver
Date: Tue, 26 Dec 2006 16:50:16 -0500
Message-ID: <45919918.1040006@garzik.org>
References: <200612192108.kBJL8ndY010501@shell0.pdx.osdl.net> <459196FD.7000600@garzik.org> <20061226214227.GB23313@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, burman.yan@gmail.com,
	rmk@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41680 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932830AbWLZVuU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Dec 2006 16:50:20 -0500
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20061226214227.GB23313@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:
> On Tue, Dec 26, 2006 at 04:41:17PM -0500, Jeff Garzik wrote:
> 
>>> Small cleanup in the Cirrus Logic EP93xx ethernet driver: Check for NULL
>>> pointer before dereferencing it instead of after.  Remove unreferenced
>>> variable.
>>>
>>> Signed-off-by: Yan Burman <burman.yan@gmail.com>
>>> Cc: Jeff Garzik <jeff@garzik.org>
>>> Cc: Russell King <rmk@arm.linux.org.uk>
>>> Signed-off-by: Andrew Morton <akpm@osdl.org>
> 
> Why wasn't I CC'ed on this?

Came via akpm, and seemed sane...

	Jeff, proceeding in full-speed-ahead mode :)






