From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: Check return value of
 alloc_dma_desc_resources()
Date: Mon, 24 Feb 2014 18:58:35 -0500 (EST)
Message-ID: <20140224.185835.1558121522876883252.davem@davemloft.net>
References: <1393070943-3466-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48473 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639AbaBXX6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 18:58:36 -0500
In-Reply-To: <1393070943-3466-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Sat, 22 Feb 2014 13:09:03 +0100

> alloc_dma_desc_resources() returns an error value and the next line
> actually checks for it, so assign the return value properly.
> 
> Found by the coverity scanner.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied, thanks.
