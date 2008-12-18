From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.29 v3 4/5] gianfar: Merge Tx and Rx interrupt for
 scheduling clean up ring
Date: Wed, 17 Dec 2008 16:53:08 -0800 (PST)
Message-ID: <20081217.165308.78144093.davem@davemloft.net>
References: <1229550175-15600-2-git-send-email-afleming@freescale.com>
	<1229550175-15600-3-git-send-email-afleming@freescale.com>
	<1229550175-15600-4-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, Dai.Haruki@freescale.com
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38124
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752729AbYLRAxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 19:53:06 -0500
In-Reply-To: <1229550175-15600-4-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Wed, 17 Dec 2008 15:42:54 -0600

> No clean up function is executed in the interrupt context by this patch.
> 
> Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
> Acked-by: Andy Fleming <afleming@freescale.com>

Applied.
