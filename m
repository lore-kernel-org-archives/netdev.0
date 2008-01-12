From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] r6040 various cleanups
Date: Sat, 12 Jan 2008 17:22:38 -0500
Message-ID: <47893DAE.9080007@garzik.org>
References: <200712121044.01820.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Sten Wang <sten.wang@rdc.com.tw>, netdev@vger.kernel.org
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50116 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754714AbYALWWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 17:22:45 -0500
In-Reply-To: <200712121044.01820.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli wrote:
> The following patch applies to Jeff's netdev-2.6 tree with Francois's r6040 recent changes pulled to this tree.
> 
> - remove unused private structure members
> - functions to allocate/free TX and RX buffers
> - recover from transmit timeout
> - use netdev_alloc_skb instead of dev_alloc_skb
> - do not use a private stats structure to store statistics
> - break each TX/RX error to a separate line for better reading
> - better control of the timer
> - clean the IRQ handler
> - fix typos and spelling mistakes in the driver
> 
> Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>

ack, but the patch was corrupted...

