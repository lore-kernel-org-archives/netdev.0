From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Wed, 22 Sep 2004 13:46:35 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922034634.GA14928@gondor.apana.org.au>
References: <20040919215915.GB9573@gondor.apana.org.au> <1095633569.1047.107.camel@jzny.localdomain> <20040919231734.GA10124@gondor.apana.org.au> <1095647944.1046.206.camel@jzny.localdomain> <20040920025802.GA11567@gondor.apana.org.au> <1095683660.1047.254.camel@jzny.localdomain> <414F1E12.6010808@eurodev.net> <20040922000503.GA13218@gondor.apana.org.au> <4150E7E5.2000001@eurodev.net> <1095821624.1045.6.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1095821624.1045.6.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Sep 21, 2004 at 10:53:44PM -0400, jamal wrote:
> 
> Its not ipsec policies, rather tc actions - but i expect the same to
> happen to ipsec policies being dumped..

Well I haven't seen any with IPsec.  Can you please provide a strace
of a failed tc dump so that I know what I'm looking for?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
