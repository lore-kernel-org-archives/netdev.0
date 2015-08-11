From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mellanox: mlxsw: Use '%zx' to print size_t
 format
Date: Mon, 10 Aug 2015 21:13:02 -0700 (PDT)
Message-ID: <20150810.211302.1759543738522988422.davem@davemloft.net>
References: <1439211268-8785-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, netdev@vger.kernel.org
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46113 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbbHKENC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 00:13:02 -0400
In-Reply-To: <1439211268-8785-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Mon, 10 Aug 2015 09:54:28 -0300

> Use '%zx' to print size_t format in order to fix the following build warning:
> 
> drivers/net/ethernet/mellanox/mlxsw/item.h:65:3: warning: format '%lx' expects argument of type 'long unsigned int', but argument 6 has type 'size_t' [-Wformat=]
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied, thanks.
