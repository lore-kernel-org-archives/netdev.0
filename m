From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: 27 Sep 2004 22:43:27 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096339407.8660.33.camel@jzny.localdomain>
References: <1095683660.1047.254.camel@jzny.localdomain>
	 <414F1E12.6010808@eurodev.net> <20040922000503.GA13218@gondor.apana.org.au>
	 <4150E7E5.2000001@eurodev.net> <20040922045239.GA19573@gondor.apana.org.au>
	 <1095854920.1047.64.camel@jzny.localdomain>
	 <20040923120707.GB32624@gondor.apana.org.au>
	 <1095995042.1044.34.camel@jzny.localdomain>
	 <20040924032440.GB6384@gondor.apana.org.au>
	 <1096289189.1075.37.camel@jzny.localdomain>
	 <20040927213607.GD7243@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040927213607.GD7243@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-09-27 at 17:36, Herbert Xu wrote:

> You still haven't told me what you're going to use 3) for yet...

Sorry, keep forgetting to retrieve it from other remote non-networked
test machine. The idea is:
Create something that generates lots of messages. Make socket buffer
small (4096 is good nuf)

cheers,
jamal
