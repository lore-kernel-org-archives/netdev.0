From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [25/*] [NET] Kill unnecessary uses of dst_path_metric
Date: Fri, 18 Mar 2005 10:44:36 -0800
Message-ID: <20050318104436.62535f2c.davem@davemloft.net>
References: <20050308102741.GA23468@gondor.apana.org.au>
	<20050314102614.GA9610@gondor.apana.org.au>
	<20050314105313.GA21001@gondor.apana.org.au>
	<20050314111002.GA29156@gondor.apana.org.au>
	<20050315091904.GA6256@gondor.apana.org.au>
	<20050315095837.GA7130@gondor.apana.org.au>
	<20050318090310.GA28443@gondor.apana.org.au>
	<20050318091129.GA28658@gondor.apana.org.au>
	<20050318091918.GA28944@gondor.apana.org.au>
	<20050318100757.GA29433@gondor.apana.org.au>
	<20050318101126.GA29583@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050318101126.GA29583@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 18 Mar 2005 21:11:26 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This gets rid of the last unnecessary use of dst_path_metric.  In
> decnet dst->path is always equal to dst.
>  
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
