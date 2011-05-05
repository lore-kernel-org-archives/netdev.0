From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: fix SJA1000 dlc for RTR packets
Date: Thu, 05 May 2011 11:02:38 -0700 (PDT)
Message-ID: <20110505.110238.48488325.davem@davemloft.net>
References: <20110502145048.GF338@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: kurt.van.dijck@eia.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35162
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752882Ab1EESDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 14:03:10 -0400
In-Reply-To: <20110502145048.GF338@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Date: Mon, 2 May 2011 16:50:48 +0200

> RTR frames do have a valid data length code on CAN.
> The driver for SJA1000 did not handle that situation properly.
> 
> Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>

Applied, thanks.
