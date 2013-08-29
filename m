From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] fec: Use NAPI_POLL_WEIGHT
Date: Thu, 29 Aug 2013 16:00:04 -0400 (EDT)
Message-ID: <20130829.160004.1943184050333559613.davem@davemloft.net>
References: <1377635708-10159-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37637 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755127Ab3H2UAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 16:00:06 -0400
In-Reply-To: <1377635708-10159-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Tue, 27 Aug 2013 17:35:08 -0300

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> Instead of using a custom 'FEC_NAPI_WEIGHT', just use the generic
> 'NAPI_POLL_WEIGHT' definition instead.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied to net-next, thanks.
