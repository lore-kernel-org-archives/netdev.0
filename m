From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Openswan dev] Re: [IPSEC] COW skb header in UDP decap
Date: Thu, 21 Apr 2005 07:26:36 +1000
Message-ID: <20050420212636.GA28424@gondor.apana.org.au>
References: <21730.1112984853@marajade.sandelman.ottawa.on.ca>
	<20050409010124.GA22059@gondor.apana.org.au>
	<20050419231741.64e44443.davem@davemloft.net>
	<Pine.LNX.4.61.0504201609160.29370@expansionpack.xtdnet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@lists.openswan.org
Return-path: <dev-bounces@openswan.org>
To: Paul Wouters <paul@xelerance.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0504201609160.29370@expansionpack.xtdnet.nl>
Cc: Michael Richardson <mcr@sandelman.ottawa.on.ca>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@oss.sgi.com
List-Unsubscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@openswan.org?subject=unsubscribe>
List-Archive: <http://lists.openswan.org/pipermail/dev>
List-Post: <mailto:dev@openswan.org>
List-Help: <mailto:dev-request@openswan.org?subject=help>
List-Subscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@openswan.org?subject=subscribe>
Sender: dev-bounces@openswan.org
Errors-To: dev-bounces@openswan.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 20, 2005 at 04:10:01PM +0200, Paul Wouters wrote:
> 
> Which reminds me. I still have hanging 'ip xfrm state' commands on 2.6.11.7

What does strace say?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
