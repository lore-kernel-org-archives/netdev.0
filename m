From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] - Incorrect cpumask definition in net/core/flow.c
Date: Sat, 8 Nov 2003 22:26:45 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031108222645.4e3d23f1.davem@redhat.com>
References: <20031107210848.GA10774@sgi.com>
	<E1AIJIT-0002q9-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: steiner@sgi.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1AIJIT-0002q9-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 08 Nov 2003 13:57:57 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Here is a patch that changes the operations on the maps as well
> for consistency.

This is the correct patch, applied thanks.

I have another patch that cleans up this stuff in a better
albeit intrusive way from Rusty, but let's be safe for 2.6.0
