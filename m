From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: Fix incorrect dst_entry handling in ip6_tunnel.c
Date: Wed, 09 Jul 2003 20:43:12 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030709.204312.68059397.davem@redhat.com>
References: <Pine.LNX.4.44.0307041601570.15229-100000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: vnuorval@tcs.hut.fi
In-Reply-To: <Pine.LNX.4.44.0307041601570.15229-100000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ville Nuorvala <vnuorval@tcs.hut.fi>
   Date: Fri, 4 Jul 2003 16:14:18 +0300 (EEST)

   I noticed a bug in ip6ip6_err(), please apply this patch!

Applied, thank you.
