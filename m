From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPSEC]: Protect against BHs in xfrm_user_policy()
Date: Mon, 4 Apr 2005 05:47:44 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0504040544010.19728@kaber.coreworks.de>
References: <4250160D.2040405@trash.net> <20050404012040.GA16960@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050404012040.GA16960@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 4 Apr 2005, Herbert Xu wrote:
> We want the same thing for km_query, no?

In all other places were BHs are not explicitly disabled
but need to be they are already disabled by the caller,
so I left them as they are.

Regards
Patrick
