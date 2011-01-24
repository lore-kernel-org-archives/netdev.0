From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/3] can: at91_can: fix for errata 50.2.6.3 &
 50.3.5.3
Date: Mon, 24 Jan 2011 15:17:10 -0800 (PST)
Message-ID: <20110124.151710.102560158.davem@davemloft.net>
References: <1295878532-15769-1-git-send-email-mkl@pengutronix.de>
	<4D3D8A64.6000305@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48429
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751300Ab1AXXQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 18:16:35 -0500
In-Reply-To: <4D3D8A64.6000305@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Mon, 24 Jan 2011 15:19:16 +0100

> I've updated the patch series in my git-repo, too.
> 
> The following changes since commit b30532515f0a62bfe17207ab00883dd262497006:
> 
>   bonding: Ensure that we unshare skbs prior to calling pskb_may_pull (2011-01-20 16:45:56 -0800)
> 
> are available in the git repository at:
>   git://git.pengutronix.de/git/mkl/linux-2.6.git can/at91_can-for-net-2.6
> 
> Marc Kleine-Budde (3):
>       can: at91_can: clean up usage of AT91_MB_RX_FIRST and AT91_MB_RX_NUM
>       can: at91_can: don't use mailbox 0
>       can: at91_can: make can_id of mailbox 0 configurable

Pulled into net-2.6, thanks Marc.
