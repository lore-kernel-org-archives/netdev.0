From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tc35815: Enable StripCRC feature
Date: Thu, 11 Dec 2008 20:58:53 -0800 (PST)
Message-ID: <20081211.205853.240166443.davem@davemloft.net>
References: <20081211.002259.07456931.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: anemo@mba.ocn.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54241
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756390AbYLLE6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 23:58:52 -0500
In-Reply-To: <20081211.002259.07456931.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Date: Thu, 11 Dec 2008 00:22:59 +0900 (JST)

> The chip can strip CRC automatically on receiving.  Enable it.
> 
> Also fix potential RX_BUF_SIZE calculation bug which was obscured by
> alignment.  And use proper symbols (NET_IP_ALIGN, ETH_FCS_LEN, etc.)
> instead of magic numbers.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> ---
> This is a revised patch.  Fixed missing backslash.

Patch applied, thanks!
