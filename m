From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] tc35815: Kill unused code
Date: Mon, 02 Nov 2009 23:45:54 -0800 (PST)
Message-ID: <20091102.234554.70051363.davem@davemloft.net>
References: <1257172487-5656-2-git-send-email-anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf.roesch@rw-gmbh.de
To: anemo@mba.ocn.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39746
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756657AbZKCHp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 02:45:29 -0500
In-Reply-To: <1257172487-5656-2-git-send-email-anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Date: Mon,  2 Nov 2009 23:34:47 +0900

> - TC35815_DMA_SYNC_ONDEMAND is always enabled.
> - WORKAROUND_LOSTCAR is always enabled.
> - WORKAROUND_100HALF_PROMISC is always enabled.
> - GATHER_TXINT is always enabled.
> - TC35815_USE_PACKEDBUFFER is always disabled.
> - NO_CHECK_CARRIER is always disabled.

Applied to net-next-2.6
