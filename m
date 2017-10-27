From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH v2] net: xfrm_user: use BUG_ON instead of if condition
 followed by BUG
Date: Fri, 27 Oct 2017 12:46:08 +0200
Message-ID: <20171027104608.GE11292@secunet.com>
References: <20171026054745.Horde.IgJuLhgV7tprdH0lZ5Pdj0U@gator4166.hostgator.com>
 <20171026113135.GA8044@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171026113135.GA8044@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 26, 2017 at 06:31:35AM -0500, Gustavo A. R. Silva wrote:
> Use BUG_ON instead of if condition followed by BUG.
> 
> This issue was detected with the help of Coccinelle.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied to ipsec-next, thanks Gustavo!
