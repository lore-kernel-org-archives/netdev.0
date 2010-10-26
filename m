From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: mcp251x: fix reception of standard RTR frames
Date: Tue, 26 Oct 2010 10:49:49 -0700 (PDT)
Message-ID: <20101026.104949.35034236.davem@davemloft.net>
References: <1287679030-13993-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48124
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755257Ab0JZRtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 13:49:25 -0400
In-Reply-To: <1287679030-13993-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Thu, 21 Oct 2010 18:37:10 +0200

> This patch sets the missing CAN_RTR_FLAG if a standard RTR frame is
> received.
> (For extended frames the CAN_RTR_FLAG was already set correctly.)
> 
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>

Applied.
