From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2] drivers/isdn: eliminate duplicated test
Date: Sun, 03 Jan 2010 21:26:26 -0800 (PST)
Message-ID: <20100103.212626.76766152.davem@davemloft.net>
References: <200912220025.nBM0PWwQ005143@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org, julia@diku.dk
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50291
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752914Ab0ADF0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 00:26:22 -0500
In-Reply-To: <200912220025.nBM0PWwQ005143@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 21 Dec 2009 16:25:32 -0800

> From: Julia Lawall <julia@diku.dk>
> 
> The code checked slot_rx twice.  Check slot_tx by analogy with the bank
> case.
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>
> Cc: Karsten Keil <isdn@linux-pingi.de>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
