From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/5] LL TEMAC driver: add non-Virtex 5 support
Date: Mon, 15 Mar 2010 16:05:48 -0700 (PDT)
Message-ID: <20100315.160548.148560063.davem@davemloft.net>
References: <201003112207.o2BM7qhv013492@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jtyner@cs.ucr.edu, afleming@freescale.com,
	grant.likely@secretlab.ca
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42717
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S937057Ab0COXF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 19:05:26 -0400
In-Reply-To: <201003112207.o2BM7qhv013492@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Thu, 11 Mar 2010 14:07:51 -0800

> From: John Tyner <jtyner@cs.ucr.edu>
> 
> Add support for using the LL TEMAC Ethernet driver on non-Virtex 5
> platforms by adding support for accessing the Soft DMA registers as if
> they were memory mapped instead of solely through the DCR's (available on
> the Virtex 5).
> 
> Signed-off-by: John Tyner <jtyner@cs.ucr.edu>
> Cc: Andy Fleming <afleming@freescale.com>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

This is still going through revision, so I'm holding off
on this.
