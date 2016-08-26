From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH -next v2] chcr: Fix non static symbol warning
Date: Fri, 26 Aug 2016 22:42:19 +0800
Message-ID: <20160826144219.GA22232@gondor.apana.org.au>
References: <1471882278-25777-1-git-send-email-weiyj.lk@gmail.com>
 <1472221268-25123-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Hariprasad Shenai <hariprasad@chelsio.com>,
        Atul Gupta <atul.gupta@chelsio.com>,
        Wei Yongjun <weiyongjun1@huawei.com>,
        linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1472221268-25123-1-git-send-email-weiyj.lk@gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 26, 2016 at 02:21:08PM +0000, Wei Yongjun wrote:
> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fixes the following sparse warning:
> 
> drivers/crypto/chelsio/chcr_algo.c:593:5: warning:
>  symbol 'cxgb4_is_crypto_q_full' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
