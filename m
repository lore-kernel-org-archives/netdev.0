From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC]: Add xfrm_input_state helper
Date: Tue, 11 Dec 2007 01:54:11 -0800 (PST)
Message-ID: <20071211.015411.76426967.davem@davemloft.net>
References: <20071211034531.GA10033@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43901
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751388AbXLKJyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 04:54:11 -0500
In-Reply-To: <20071211034531.GA10033@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 11 Dec 2007 11:45:31 +0800

> [IPSEC]: Add xfrm_input_state helper
> 
> This patch adds the xfrm_input_state helper function which returns the
> current xfrm state being processed on the input path given an sk_buff.
> This is currently only used by xfrm_input but will be used by ESP upon
> asynchronous resumption.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25, thanks!
