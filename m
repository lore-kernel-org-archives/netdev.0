From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: ipv6-in-ipv6 tunnel using alloc_netdev
Date: Wed, 09 Jul 2003 22:47:00 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030709.224700.27801124.davem@redhat.com>
References: <Pine.LNX.4.44.0307041614290.15229-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: vnuorval@tcs.hut.fi
In-Reply-To: <Pine.LNX.4.44.0307041614290.15229-200000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ville Nuorvala <vnuorval@tcs.hut.fi>
   Date: Fri, 4 Jul 2003 23:23:44 +0300 (EEST)

   I finally had the time to fix ip6_tunnel.c so it also uses alloc_netdev()
   for creating new tunnel devices.
   
   Tested by adding and deleting tunnel device. Patch as attachment...

Applied, thanks.
