From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.9-rc2-mm2 fn_hash_insert oops
Date: Thu, 23 Sep 2004 13:36:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923133604.26a2ea2a.davem@davemloft.net>
References: <20040923103723.GA12145@mail.muni.cz>
	<E1CARaS-00071j-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xhejtman@mail.muni.cz, akpm@osdl.org, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CARaS-00071j-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 23 Sep 2004 21:16:32 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Lukas Hejtmanek <xhejtman@mail.muni.cz> wrote:
> > 
> > However there is still the issue with endless loop in fn_hash_delete :(
> 
> Same problem, same fix.

Applied, thanks Herbert.
