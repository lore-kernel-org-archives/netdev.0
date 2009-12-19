From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] gianfar: Fix stats support
Date: Fri, 18 Dec 2009 20:38:55 -0800 (PST)
Message-ID: <20091218.203855.242132032.davem@davemloft.net>
References: <1260962107-16855-1-git-send-email-Sandeep.Kumar@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, avorontsov@ru.mvista.com,
	eric.dumazet@gmail.com
To: Sandeep.Kumar@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44732
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756054AbZLSEix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 23:38:53 -0500
In-Reply-To: <1260962107-16855-1-git-send-email-Sandeep.Kumar@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
Date: Wed, 16 Dec 2009 16:45:07 +0530

> This patch updates the per rx/tx queue stats.
> To update the per rx queue stats a new structure has been
> introduced rx_q_stats.
> The per tx queue stats are updated via the netdev_queue
> structure itself.
> 
> Note that we update only the tx_packtes, tx_bytes, rx_packets,
> rx_bytes and rx_dropped stats on a per queue basis.
> 
> Signed-off-by: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>

Applied.
