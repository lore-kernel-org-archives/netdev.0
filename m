From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch]net/xfrm/xfrm_policy.c: replace timer with delayed_work
Date: Mon, 28 Apr 2008 23:13:42 +0800
Message-ID: <20080428151342.GA12007@gondor.apana.org.au>
References: <20080216.235534.237382205.xiyou.wangcong@gmail.com> <20080427011809.GA662@gondor.apana.org.au> <20080428.225312.58450957.xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net, akpm@osdl.org,
	netdev@vger.kernel.org
To: WANG Cong <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36472 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934062AbYD1PNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 11:13:49 -0400
Content-Disposition: inline
In-Reply-To: <20080428.225312.58450957.xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 28, 2008 at 10:53:12PM +0800, WANG Cong wrote:
>
> Do you mean ->lock of struct xfrm_policy?
> OK. I will recook these two patches soon.

Yep.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
