From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Fix target address for (proxy/anycast) NA
Date: Wed, 20 Aug 2003 11:20:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820112034.1f0158b1.davem@redhat.com>
References: <20030819083621.2ae4abc8.davem@redhat.com>
	<Pine.LNX.4.44.0308192019030.27510-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0308192019030.27510-200000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 20 Aug 2003 14:23:12 +0300 (EEST)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> the target address in neighbor advertisements must be the solicited
> address. Otherwise proxy NAs (and NAs for anycast addresses) don't work.

Applied, thanks.
