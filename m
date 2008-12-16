From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.29 01/14] gianfar: Use gfar_halt to stop DMA in
 gfar_probe
Date: Tue, 16 Dec 2008 15:25:53 -0800 (PST)
Message-ID: <20081216.152553.259448468.davem@davemloft.net>
References: <1229469667-25002-1-git-send-email-afleming@freescale.com>
	<1229469667-25002-2-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, galak@kernel.crashing.org, netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37278
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754251AbYLPXZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:25:52 -0500
In-Reply-To: <1229469667-25002-2-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Tue, 16 Dec 2008 17:20:54 -0600

> gfar_halt does everything we want to do there, including disabling
> TX/RX.  It also doesn't unnecessarily enable DMA if it's already
> stopped.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Applied.
