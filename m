From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: sctp: Fix a_rwnd/rwnd management to reflect
 real state of the receiver's buffer
Date: Mon, 17 Feb 2014 00:17:19 -0500 (EST)
Message-ID: <20140217.001719.972154075645167962.davem@davemloft.net>
References: <52FE1F56.2020007@nsn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	alexander.sverdlin@nsn.com
To: matija.glavinic-pecotic.ext@nsn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40087 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbaBQFRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 00:17:21 -0500
In-Reply-To: <52FE1F56.2020007@nsn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>
Date: Fri, 14 Feb 2014 14:51:18 +0100

> Implementation of (a)rwnd calculation might lead to severe performance issues
> and associations completely stalling. These problems are described and solution
> is proposed which improves lksctp's robustness in congestion state.
 ...
> Signed-off-by: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>
> Reviewed-by: Alexander Sverdlin <alexander.sverdlin@nsn.com>

Applied, thanks.
