From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RESEND #4/patch 2.6.26-rc6] net/enc28j60: section fix
Date: Tue, 17 Jun 2008 23:26:14 -0400
Message-ID: <48588056.2000605@garzik.org>
References: <200806122136.24921.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Claudio Lanconelli <lanconelli.claudio@eptar.com>,
	lkml <linux-kernel@vger.kernel.org>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40542 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756833AbYFRD0T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 23:26:19 -0400
In-Reply-To: <200806122136.24921.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Brownell wrote:
> Minor bugfixes to the enc28j60 driver ... wrong section marking,
> indentation, and bogus use of spi_bus_type.
> 
> Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
> Acked-by: Claudio Lanconelli <lanconelli.claudio@eptar.com>
> ---
> Previously sent:  18-April, 19-February, 6-February.
> 
>  drivers/net/enc28j60.c |    5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)

applied


