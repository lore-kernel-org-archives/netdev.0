From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NET] Fix neighbour tbl->entries race
Date: Tue, 9 Nov 2004 21:41:11 -0800
Message-ID: <20041109214111.59be601f.davem@davemloft.net>
References: <20041102112651.GA8633@gondor.apana.org.au>
	<1099404823.1021.15.camel@jzny.localdomain>
	<20041102203720.GA12108@gondor.apana.org.au>
	<20041102210259.GA12642@gondor.apana.org.au>
	<20041102220603.GA13312@gondor.apana.org.au>
	<20041103155438.07a219ad.davem@davemloft.net>
	<20041107080839.GA26158@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041107080839.GA26158@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 7 Nov 2004 19:08:39 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Sure.  BTW this bug is a lot older than the new neighbours code.
> It's in the very first revision of neighbour.c :)

Indeed. :-)

Patch applied, thanks a lot Herbert.
