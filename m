From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Also fix tunnel skb->h.raw bug in ip6_tunnel.c
Date: Wed, 5 Nov 2003 12:34:08 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031105123408.5db4d1ec.davem@redhat.com>
References: <Pine.LNX.4.58.0311051253420.27592@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.58.0311051253420.27592@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 5 Nov 2003 13:02:02 +0200 (EET)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> I noticed the skb->h.raw bug was fixed for ipip.c, ip_gre.c and sit.c, but
> not for ip6_tunnel.c. Here is a patch for it as well. Please apply!

Applied, thanks Ville.
