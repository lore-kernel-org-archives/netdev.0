From: David Miller <davem@davemloft.net>
Subject: Re: netdrv: Fix unregister_netdev typos
Date: Sun, 05 Oct 2008 09:20:43 -0700 (PDT)
Message-ID: <20081005.092043.136647898.davem@davemloft.net>
References: <20081005043038.GA12449@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57011
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758752AbYJEQVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 12:21:08 -0400
In-Reply-To: <20081005043038.GA12449@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 5 Oct 2008 12:30:38 +0800

> netdrv: Fix unregister_netdev typos
> 
> Found during the (partial) unregister_netdevice audit that we didn't
> have to have :)
> 
> It looks like a couple of Sun NIC drivers had unregister_netdevice
> when they really meant unregister_netdev.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
