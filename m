From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: nicer log message on Siena SR-IOV probe
 fail
Date: Mon, 18 May 2015 16:21:10 -0400 (EDT)
Message-ID: <20150518.162110.662071662680177755.davem@davemloft.net>
References: <5559E6A3.1090109@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59877 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932359AbbERUVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 16:21:13 -0400
In-Reply-To: <5559E6A3.1090109@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Mon, 18 May 2015 14:18:27 +0100

> We expect that MC_CMD_SRIOV will fail if the card has no VFs configured.
> So output a readable message instead of a cryptic MCDI error.
> 
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Applied, thank you.
