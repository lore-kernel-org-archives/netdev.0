From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC, PATCH 1/5]: netfilter+ipsec - nf_reset
Date: Thu, 18 Mar 2004 22:08:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040318220825.5d3bf6e8.davem@redhat.com>
References: <20040308110331.GA20719@gondor.apana.org.au>
	<404C874D.4000907@trash.net>
	<20040308115858.75cdddca.davem@redhat.com>
	<4059CEDF.6030209@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4059CEDF.6030209@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Mar 2004 17:31:27 +0100
Patrick McHardy <kaber@trash.net> wrote:

> This patch adds a new function nf_reset to reset netfilter
> related skb-fields. It has no real relationship to
> netfilter+ipsec, but it's required for the follow-up patches.

I like and thus want this cleanup regardless of what happens
to the rest of your patches :)
