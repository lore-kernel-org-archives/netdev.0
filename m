From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default
 configurable
Date: Tue, 30 Jun 2009 12:06:08 -0700 (PDT)
Message-ID: <20090630.120608.193727499.davem@davemloft.net>
References: <1246379267.3749.42.camel@blaa>
	<20090630170027.GA22691@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090630170027.GA22691@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 1 Jul 2009 01:00:27 +0800

Adding appropriate lists and persons to CC:

> On Tue, Jun 30, 2009 at 05:27:47PM +0100, Mark McLoughlin wrote:
>> 
>> However, because nf_conntrack introduces an skb_orphan(), it is now
>> recommended that bridge-nf-call-iptables be disabled completely so as
>> to ensure features like TUNSETSNDBUF work as expected.
> 
> Patrick, does conntrack ever make sense for bridging? Perhaps
> we should get rid of that completely?
> 
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
