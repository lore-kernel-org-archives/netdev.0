From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Fix tunnel encapsulation limit in ip6_tunnel.c
Date: Mon, 18 Aug 2003 04:48:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818044810.01a28c38.davem@redhat.com>
References: <Pine.LNX.4.44.0308181423250.19167-100000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0308181423250.19167-100000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 14:50:51 +0300 (EEST)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> I reread RFC 2473 and noticed the tunnel encapsulation limit handling was
> off by one. This patch fixes the bug. Please apply!

Applied, thanks Ville.
