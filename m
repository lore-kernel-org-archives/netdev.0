From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [IP6IP6] Handle ECN correctly
Date: Thu, 9 Sep 2004 10:04:33 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409091002570.22873-100000@netcore.fi>
References: <20040908214926.51b56a66.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Herbert Xu <herbert@gondor.apana.org.au>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040908214926.51b56a66.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 8 Sep 2004, David S. Miller wrote:
> We were going to make all the ipv4 tunnels offer encapsulation
> behavior for these fields that matched the two major models
> of behavior described in the IP tunneling RFCs.
> 
> Specifically I'm talking about the Uniform and the Pipe model
> described in RFC-2983.

Now that we're talking about RFCs and tunnels, I'd like to point out 
draft-ietf-v6ops-mech-v2-06.txt which replaces the old v6-in-v4 
tunneling RFC, and is at the point of approval as RFC.

Sorry for hijacking the thread :)

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
