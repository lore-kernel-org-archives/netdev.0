From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: (5/5+1) Autoconfig link-local addr to IPv6
 tunnels
Date: Tue, 2 Sep 2003 04:35:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030902043534.05fc6586.davem@redhat.com>
References: <20030901035134.2585aa79.davem@redhat.com>
	<Pine.LNX.4.44.0309011709370.29198-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, yoshfuji@linux-ipv6.org, usagi-core@linux-ipv6.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0309011709370.29198-200000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 1 Sep 2003 17:24:42 +0300 (EEST)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> Ok, this incremental patch to my previous addrconf.c patch generates a
> link-local address to the IPv6 tunnel device. It first tries to inherit
> the EUI64 identifier of some other device and if this fails, uses a
> random interface id.

Yoshfuji, do you mind if I apply his patch 5 and "5/5+1"?
