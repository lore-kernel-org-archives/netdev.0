From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 4/7] fsl_pq_mdio: Add Suport for etsec2.0 devices.
Date: Thu, 29 Oct 2009 03:16:10 -0700 (PDT)
Message-ID: <20091029.031610.04742718.davem@davemloft.net>
References: <9F4C7D19E8361D4C94921B95BE08B81B950352@zin33exm22.fsl.freescale.net>
	<20091029.024546.90958594.davem@davemloft.net>
	<9F4C7D19E8361D4C94921B95BE08B81B95035E@zin33exm22.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, avorontsov@ru.mvista.com
To: B05799@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40766
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753879AbZJ2KPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 06:15:46 -0400
In-Reply-To: <9F4C7D19E8361D4C94921B95BE08B81B95035E@zin33exm22.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Date: Thu, 29 Oct 2009 15:41:22 +0530

> This is the tree I generated the patches against initially. 
> The initial set of patches were generated against this tree:
> (http://www.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git)
> 
> Can you please confirm that the above tree is correct.

Yes.

> The patches sent by me applies cleanly to the above mentioned
> net-next-2.6 tree. 

It may have applied cleanly when you sent them, but by the
time I applied them it didn't.

Resend a fresh patch set against a fresh net-next-2.6 checkout
and let's see what happens :-)
