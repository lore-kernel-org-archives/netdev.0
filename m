From: David Miller <davem@davemloft.net>
Subject: Re: [0/2] tun: Fix csum_start and TUN_PKT_STRIP
Date: Mon, 03 Nov 2014 14:28:57 -0500 (EST)
Message-ID: <20141103.142857.1883643619167908988.davem@davemloft.net>
References: <20141102202929.GA24935@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48671 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753307AbaKCT3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 14:29:02 -0500
In-Reply-To: <20141102202929.GA24935@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 3 Nov 2014 04:29:30 +0800

> The first patch fixes a serious problem that breaks checksum offload
> in VMs while the second patch fixes a problem that probably affects
> no one.

Series applied, thanks Herbert.
