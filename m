From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/can: activate bit-timing calculation and netlink
 based drivers by default
Date: Wed, 29 Jun 2011 05:58:55 -0700 (PDT)
Message-ID: <20110629.055855.2052735868060031598.davem@davemloft.net>
References: <1309160391-22486-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: socketcan-users@lists.berlios.de, wg@grandegger.com,
	netdev@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50467 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009Ab1F2NAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 09:00:06 -0400
In-Reply-To: <1309160391-22486-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Mon, 27 Jun 2011 09:39:51 +0200

> The two options "CAN bit-timing calculation" and
> "Platform CAN drivers with Netlink support" have a "default Y". In order to
> activate them by default, change to "default y".
> 
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>

Applied.
