From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: (4/5) Remove sockets from ip6_tunnel.c
Date: Mon, 1 Sep 2003 01:48:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030901014845.660a9471.davem@redhat.com>
References: <Pine.LNX.4.44.0309010238110.26242-200000@rhea.tcs.hut.fi>
	<Pine.LNX.4.44.0309010249070.26242-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0309010249070.26242-200000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 1 Sep 2003 02:57:03 +0300 (EEST)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> this patch removes all sockets from ip6_tunnel.c. It also allows nested
> IPv6 encapsulations through different devices in the IPv6 tunnel
> entry-point node, since the old restrictions caused by the sockets don't
> apply any more. Please apply the patch!

Thank you very much for finishing this work.

Applied, thanks.
