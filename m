From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPv6 multicast (MLD,IGMP) code bypasses netfilter hooks
Date: Sun, 23 Nov 2003 15:43:44 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031123154344.3e2b0b1a.davem@redhat.com>
References: <20031122090330.GB2745@obroa-skai.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20031122090330.GB2745@obroa-skai.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 22 Nov 2003 10:03:30 +0100
Harald Welte <laforge@netfilter.org> wrote:

> At least to me it was not known (until very recently) that the IPv6
> multicast code in net/ipv6/mcast.c bypasses the netfilter hooks - but it
> does.
 ...
> Dave: I think this would be post 2.6.0 stuff, wouldn't it?

If the fix is simple enough (1 or 2 one-liner changes) and easy
to verify, I would consider it for 2.6.0

I may even look into this myself.

Thanks Harald.
