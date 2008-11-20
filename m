From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix asix-based gigabit cards connecting to 10 or
 100Mbs networks
Date: Thu, 20 Nov 2008 00:29:35 -0800 (PST)
Message-ID: <20081120.002935.212270771.davem@davemloft.net>
References: <1295ed070811171041j1258ec41kc6b1db61e83b628e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pktoss@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54710
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752607AbYKTI3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 03:29:35 -0500
In-Reply-To: <1295ed070811171041j1258ec41kc6b1db61e83b628e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Pantelis Koukousoulas" <pktoss@gmail.com>
Date: Mon, 17 Nov 2008 20:41:57 +0200

> Add AX_MEDIUM_ENCK also when speed = 10/100Mbps. This allows my belkin
>  f5d5055 to work with my 100Mbps switch and with an old 10Mbps ISA card.
>  Without this patch, the card is recognized and the interface is brought
>  up fine, but no packets actually flow through the interface.
> 
>  Signed-off-by: Pantelis Koukousoulas <pktoss@gmail.com>
>  Acked-by: David Hollis <dhollis@davehollis.com>

This patch has been severely corrupted by your email client.

Please use the tips in linux/Documentation/email-clients.txt to
fix this up and then make a full resubmission (including commit
log message and signoffs).

Thanks!
