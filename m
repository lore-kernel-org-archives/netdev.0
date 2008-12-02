From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] xfrm: Cleanup for unlink SPD entry
Date: Tue, 2 Dec 2008 14:53:24 +0800
Message-ID: <20081202065324.GA29524@gondor.apana.org.au>
References: <493383E9.50509@cn.fujitsu.com> <4933975E.3030503@cn.fujitsu.com> <20081201081111.GA19615@gondor.apana.org.au> <20081201.003821.42061993.davem@davemloft.net> <4933B488.3000406@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38717 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751126AbYLBGxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 01:53:32 -0500
Content-Disposition: inline
In-Reply-To: <4933B488.3000406@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 01, 2008 at 05:55:20PM +0800, Wei Yongjun wrote:
> Used __xfrm_policy_unlink() to instead of the dup codes when unlink
> SPD entry.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Both patches look good to me.  Thanks!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
