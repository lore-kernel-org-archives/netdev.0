From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] KS8851: Correct RX packet allocation
Date: Wed, 08 Sep 2010 21:47:27 -0700 (PDT)
Message-ID: <20100908.214727.214214200.davem@davemloft.net>
References: <27F9C60D11D683428E133F85D2BB4A530450AB386D@dlee03.ent.ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	santosh.shilimkar@ti.com, Tristram.Ha@micrel.com
To: x0066660@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57573
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751368Ab0IIErK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 00:47:10 -0400
In-Reply-To: <27F9C60D11D683428E133F85D2BB4A530450AB386D@dlee03.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Arce, Abraham" <x0066660@ti.com>
Date: Wed, 8 Sep 2010 18:26:55 -0500

> From: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Use netdev_alloc_skb_ip_align() helper and do correct allocation
> 
> Tested-by: Abraham Arce <x0066660@ti.com>
> Signed-off-by: Abraham Arce <x0066660@ti.com>

Applied, thank you.
