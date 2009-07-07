From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix OF fixed-link property handling on Freescale
 network device drivers
Date: Mon, 06 Jul 2009 19:07:53 -0700 (PDT)
Message-ID: <20090706.190753.85468651.davem@davemloft.net>
References: <20090703221851.23909.923.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avorontsov@ru.mvista.com, leoli@freescale.com,
	afleming@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: grant.likely@secretlab.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51422
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754829AbZGGCHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 22:07:46 -0400
In-Reply-To: <20090703221851.23909.923.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>
Date: Fri, 03 Jul 2009 16:20:19 -0600

> Anton, can you please review, comment and test?  I've tested it on an
> mpc8349 board, but that is the only hardware that I have.  I've also
> probably made mistakes and it needs to be split up into separate patches,
> but this is probably a sufficient form for first review.  I'll also give
> it another once over tomorrow when after I've had a decent night sleep.

Can we get some review and testing of this patch going so we
can fix this regression as soon as possible?

Thanks.
