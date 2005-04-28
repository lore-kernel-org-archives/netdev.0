From: "David S. Miller" <davem@davemloft.net>
Subject: Re: patch: policy update by id
Date: Wed, 27 Apr 2005 19:43:56 -0700
Message-ID: <20050427194356.58a3e618.davem@davemloft.net>
References: <1114602874.7670.4.camel@localhost.localdomain>
	<1114604657.7670.22.camel@localhost.localdomain>
	<1114604826.7670.24.camel@localhost.localdomain>
	<20050427233924.GA22238@gondor.apana.org.au>
	<1114650816.7663.13.camel@localhost.localdomain>
	<20050428012135.GA22950@gondor.apana.org.au>
	<20050428013014.GA23043@gondor.apana.org.au>
	<1114653140.7663.36.camel@localhost.localdomain>
	<20050428020754.GA23326@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050428020754.GA23326@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 28 Apr 2005 12:07:54 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> You know what, I actually agree with you :) But you'll need to convince
> Dave:
> 
> http://www.uwsg.iu.edu/hypermail/linux/net/0305.3/0018.html

I'm willing to reneg on that position if you can convince me
that security minded folks won't be surprised by this pseudo-
aliasing.  For example, do firewall systems tend to support
such priority schemes?  If so, I guess we can do it.
