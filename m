From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Clean up fib_hash datastructures
Date: 21 Sep 2004 07:03:41 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095764621.1049.14.camel@jzny.localdomain>
References: <20040918203319.24004d6e.davem@davemloft.net>
	 <1095645106.1048.190.camel@jzny.localdomain>
	 <20040919195351.0b3560e6.davem@davemloft.net>
	 <1095686672.1049.301.camel@jzny.localdomain>
	 <20040920121123.70baf895.davem@davemloft.net>
	 <20040921034212.GA28462@gondor.apana.org.au>
	 <20040920231805.3f18479c.davem@davemloft.net>
	 <20040921090423.GE8058@wotan.suse.de>
	 <20040921093252.GA32545@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040921093252.GA32545@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-21 at 05:32, Herbert Xu wrote:

> If we were doing this from scratch then we should do that.  But as it
> is we must keep the TOS code for compatibility.

Important for marketing to be able to claim _full_ RFC 1812 compliance.
Kepp the TOS!
I know it sounds silly, but there are a lot more foolish people out
there addicted to glossyware.

cheers,
jamal
