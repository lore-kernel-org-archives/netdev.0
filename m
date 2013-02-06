From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] bgmac: fixes and more netdev ops
Date: Wed, 06 Feb 2013 16:07:23 -0500 (EST)
Message-ID: <20130206.160723.712091256156428111.davem@davemloft.net>
References: <1360161900-2330-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zajec5@gmail.com, netdev@vger.kernel.org
To: hauke@hauke-m.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43791 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757465Ab3BFVHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 16:07:25 -0500
In-Reply-To: <1360161900-2330-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hauke Mehrtens <hauke@hauke-m.de>
Date: Wed,  6 Feb 2013 15:44:56 +0100

> The first patch implements a TODO in the driver.
> The other patches are fixing or adding some netdev ops.
> 
> This is based on current master of davem/net-next.git.
> 
> Hauke Mehrtens (4):
>   bgmac: implement missing code for BCM53572
>   bgmac: write mac address to hardware in ndo_set_mac_address
>   bgmac: add generic ndo_validate_addr netdev ops
>   bgmac: add ndo_set_rx_mode netdev ops

Applied with updated version of patch #4.
