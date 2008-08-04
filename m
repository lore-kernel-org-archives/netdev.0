From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet6: Fix paramater issue of inet6_csk_xmit
Date: Sun, 03 Aug 2008 21:15:24 -0700 (PDT)
Message-ID: <20080803.211524.15249302.davem@davemloft.net>
References: <4896554C.3040404@hp.com>
	<E1KPpI7-0001jn-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, kuznet@ms2.inr.ac.ru,
	yjwei@cn.fujitsu.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38245
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750903AbYHDEPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 00:15:24 -0400
In-Reply-To: <E1KPpI7-0001jn-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 04 Aug 2008 09:55:19 +0800

> sctp: Drop ipfargok in sctp_xmit function
 ...
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
