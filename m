From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH] IPv6: (2/5) Use free_netdev() as destructor in ip6_tunnel.c
Date: Mon, 1 Sep 2003 02:37:40 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309010235070.26242-100000@rhea.tcs.hut.fi>
References: <Pine.LNX.4.44.0309010230180.26242-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, <usagi-core@linux-ipv6.org>
In-Reply-To: <Pine.LNX.4.44.0309010230180.26242-200000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

this patch sets free_netdev() as the destructor for ip6_tnl dev. Please
apply!

Thanks,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
