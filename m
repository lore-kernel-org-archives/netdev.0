From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Wed, 22 Sep 2004 10:52:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922105221.59a67d4b.davem@davemloft.net>
References: <414DF11C.1080505@eurodev.net>
	<20040919215915.GB9573@gondor.apana.org.au>
	<1095633569.1047.107.camel@jzny.localdomain>
	<20040919231734.GA10124@gondor.apana.org.au>
	<1095647944.1046.206.camel@jzny.localdomain>
	<20040920025802.GA11567@gondor.apana.org.au>
	<1095683660.1047.254.camel@jzny.localdomain>
	<414F1E12.6010808@eurodev.net>
	<20040922000503.GA13218@gondor.apana.org.au>
	<4150E7E5.2000001@eurodev.net>
	<20040922045239.GA19573@gondor.apana.org.au>
	<1095854920.1047.64.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, pablo@eurodev.net, davem@redhat.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1095854920.1047.64.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 22 Sep 2004 08:08:40 -0400
jamal <hadi@cyberus.ca> wrote:

> Note also, theres a lot of wastage of that scarce sock buffer via page
> sized skbs - its not as trivial to fix, but would go some way to improve
> overrunning of the socket.

Thanks for reminding me about this.
