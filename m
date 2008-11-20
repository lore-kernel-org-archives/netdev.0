From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix asix-based cards connecting to 10/100Mbs LAN.
Date: Thu, 20 Nov 2008 01:48:55 -0800 (PST)
Message-ID: <20081120.014855.141891162.davem@davemloft.net>
References: <1227174463-18158-1-git-send-email-pktoss@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pktoss@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41038
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753746AbYKTJsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 04:48:55 -0500
In-Reply-To: <1227174463-18158-1-git-send-email-pktoss@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pantelis Koukousoulas <pktoss@gmail.com>
Date: Thu, 20 Nov 2008 11:47:43 +0200

> Add AX_MEDIUM_ENCK also when speed = 10/100Mbps. This allows my belkin
>  f5d5055 to work with my 100Mbps switch and with an old 10Mbps ISA card.
>  Without this patch, the card is recognized and the interface is brought
>  up fine, but no packets actually flow through the interface.
> 
> Signed-off-by: Pantelis Koukousoulas <pktoss@gmail.com>
> Acked-by: David Hollis <dhollis@davehollis.com>

Patch applied, thank you.
