From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Flowinfo fix in ip6_tunnel.c
Date: Wed, 5 Nov 2003 12:35:08 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031105123508.20599fc6.davem@redhat.com>
References: <Pine.LNX.4.58.0311051302140.27592@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.58.0311051302140.27592@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 5 Nov 2003 13:35:33 +0200 (EET)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> would you also apply this minor patch? This makes the handling of
> flowlabels consistent with the way flowlabels are passed from userspace
> using sockopts.

This looks fine, applied thanks.
