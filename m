From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 4/7] fsl_pq_mdio: Add Suport for etsec2.0 devices.
Date: Thu, 29 Oct 2009 02:45:46 -0700 (PDT)
Message-ID: <20091029.024546.90958594.davem@davemloft.net>
References: <12566625182528-git-send-email-sandeep.kumar@freescale.com>
	<20091028.024325.134189895.davem@davemloft.net>
	<9F4C7D19E8361D4C94921B95BE08B81B950352@zin33exm22.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, avorontsov@ru.mvista.com
To: B05799@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50484
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752550AbZJ2JpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 05:45:23 -0400
In-Reply-To: <9F4C7D19E8361D4C94921B95BE08B81B950352@zin33exm22.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Date: Thu, 29 Oct 2009 15:02:44 +0530

> The absence of the above mentioned commit in the net-next-2.6 tree
> is causing some issues with patches getting applied.

You should never use linux-next as you base for working against
other people's trees.

Instead, clone net-next-2.6 and work purely against that when sending
me patches.
