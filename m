From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 3/3 XFRM]: Fix invalid key for lookup of cached bundles
Date: Mon, 14 Mar 2005 22:14:48 -0800
Message-ID: <20050314221448.7858aaa4.davem@davemloft.net>
References: <422AF8D0.3010905@trash.net>
	<20050307012458.GA4335@gondor.apana.org.au>
	<422BB14A.5030302@trash.net>
	<20050307014337.GA4451@gondor.apana.org.au>
	<422BB477.3040607@trash.net>
	<20050307015943.GA4533@gondor.apana.org.au>
	<422BBCC2.4010706@trash.net>
	<20050307025723.GA4818@gondor.apana.org.au>
	<422BC655.5070907@trash.net>
	<20050314215122.356ea961.davem@davemloft.net>
	<20050315060153.GA3282@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050315060153.GA3282@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Mar 2005 17:01:53 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> I think the conclusion is that until we fix the bundle scalability
> problem there is no point in adding tos/fwmark support here.

Aha, I see.  I misinterpreted the end of the discussion.

Thanks for clearing things up.
