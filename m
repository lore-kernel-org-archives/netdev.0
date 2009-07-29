From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH V3] CAN: Add Flexcan CAN controller driver
Date: Wed, 29 Jul 2009 10:45:53 +0200
Message-ID: <4A700C41.7030501@hartkopp.net>
References: <20090729082010.GZ2714@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Socketcan-core@lists.berlios.de
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:36934 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774AbZG2Ip5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 04:45:57 -0400
In-Reply-To: <20090729082010.GZ2714@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sascha Hauer wrote:
> And another go...
> 
> Sascha
> 
> 
> From 9f6f6fb67d57d082e056dec8121f1423c1b4fa0b Mon Sep 17 00:00:00 2001
> From: Sascha Hauer <s.hauer@pengutronix.de>
> Date: Tue, 21 Jul 2009 10:47:19 +0200
> Subject: [PATCH] CAN: Add Flexcan CAN driver
> 
> This core is found on some Freescale SoCs and also some Coldfire
> SoCs. Support for Coldfire is missing though at the moment as
> they have an older revision of the core which does not have RX FIFO
> support.
> 
> V3: integrated comments from Oliver Hartkopp
> V2: integrated comments from Wolfgang Grandegger
> 
> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>

Thanks Sascha!

The register access and the transition between the struct can_frame became
much clearer now.

Looks good to me.

Best regards,
Oliver
