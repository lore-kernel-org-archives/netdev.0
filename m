From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: network delays, mysterious push packets
Date: Tue, 07 Feb 2006 12:18:11 +1100
Message-ID: <E1F6HUh-0002rD-00@gondolin.me.apana.org.au>
References: <20060206.155028.115708927.davem@davemloft.net>
Cc: david.carlton@sun.com, linux-kernel@vger.kernel.org,
	linux-net@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20060206.155028.115708927.davem@davemloft.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
> From: David Carlton <david.carlton@sun.com>
> Date: Mon, 06 Feb 2006 14:38:10 -0800
> 
>> I'm working on an application that we're trying to switch from a 2.4
>> kernel to a 2.6 kernel.  (I believe we're using 2.6.9.)  One part of
>> the program periodically sends out chunks of data (whose size is just
>> over 1MB) via tcp.
> 
> Please reproduce with something more current and report to the correct
> mailing list (netdev@vger.kernel.org).

Please include a packet dump too.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
