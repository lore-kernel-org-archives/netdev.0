From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: (3/5) Set dev->dev_addr and dev->broadcast in
 ip6_tnls
Date: Mon, 1 Sep 2003 01:47:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030901014722.4f2d27bd.davem@redhat.com>
References: <Pine.LNX.4.44.0309010235070.26242-100000@rhea.tcs.hut.fi>
	<Pine.LNX.4.44.0309010238110.26242-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0309010238110.26242-200000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 1 Sep 2003 02:48:55 +0300 (EEST)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> I just only recently noticed MAX_ADDR_LEN had beed increased to 32. This
> means the IPv6 addresses can now be copied into the dev->dev_addr and
> dev->broadcast fields, just like the IPv4 addresses are for the other
> tunnel drivers. Please apply!

Applied, thanks Ville.
