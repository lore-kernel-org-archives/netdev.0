From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH v2] ipv6: esp6: use BUG_ON instead of if condition
 followed by BUG
Date: Fri, 27 Oct 2017 12:46:54 +0200
Message-ID: <20171027104653.GF11292@secunet.com>
References: <20171025040750.GB1999@gondor.apana.org.au>
 <20171026125106.GA13009@embeddedor.com>
 <20171026223836.GB8783@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        "Hideaki YOSHIFUJI" <yoshfuji@linux-ipv6.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171026223836.GB8783@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 27, 2017 at 06:38:36AM +0800, Herbert Xu wrote:
> On Thu, Oct 26, 2017 at 07:51:06AM -0500, Gustavo A. R. Silva wrote:
> > Use BUG_ON instead of if condition followed by BUG in esp_remove_trailer.
> > 
> > This issue was detected with the help of Coccinelle.
> > 
> > Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to ipsec-next, thanks everyone!
