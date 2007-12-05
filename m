From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3] [UDP]: Restore missing inDatagrams increments
Date: Wed, 5 Dec 2007 20:10:28 +1100
Message-ID: <20071205091028.GA15006@gondor.apana.org.au>
References: <20071204125844.GA2750@gondor.apana.org.au> <20071204130109.GA3098@gondor.apana.org.au> <47560215.6050104@cn.fujitsu.com> <20071205021559.GA27707@gondor.apana.org.au> <475663D4.9040806@cn.fujitsu.com> <20071205090228.GA14659@gondor.apana.org.au> <475669B0.4030501@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4872 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750892AbXLEJKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 04:10:34 -0500
Content-Disposition: inline
In-Reply-To: <475669B0.4030501@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 05, 2007 at 05:04:48PM +0800, Wang Chen wrote:
>
> Yes, now, sunrpc only supports INET and INET6.
> But UDPX_INC_STATS_BH is defined in udp.h, in case others use it :)

Which other family would that be :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
