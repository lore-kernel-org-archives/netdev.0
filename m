From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 4/7] fsl_pq_mdio: Add Suport for etsec2.0 devices.
Date: Fri, 30 Oct 2009 00:59:24 -0700 (PDT)
Message-ID: <20091030.005924.56385149.davem@davemloft.net>
References: <1256826229-529-1-git-send-email-Sandeep.Kumar@freescale.com>
	<20091029.212142.189578068.davem@davemloft.net>
	<9F4C7D19E8361D4C94921B95BE08B81B9503CA@zin33exm22.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com
To: B05799@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55675
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754581AbZJ3H7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 03:59:00 -0400
In-Reply-To: <9F4C7D19E8361D4C94921B95BE08B81B9503CA@zin33exm22.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Date: Fri, 30 Oct 2009 12:52:29 +0530

> 
> 1. The patch failure is due to the absence of following commit in
> net-next-2.6 tree.
> 	
> 	commit e72701acbe0b35e52d3f04d442837c06b4e64f1c
> 	Author: Anton Vorontsov <avorontsov@ru.mvista.com>
> 	Date:   Wed Oct 14 14:54:52 2009 -0700

It is in the net-next-2.6 tree, something is wrong with your
clone.

davem@sunset:~/src/GIT/net-next-2.6$ git describe e72701acbe0b35e52d3f04d442837c06b4e64f1c
v2.6.31-9041-ge72701a
davem@sunset:~/src/GIT/net-next-2.6$ 
