From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.9-rc4-mm1] [m32r] Fix smc91x driver for m32r
Date: Thu, 14 Oct 2004 10:21:51 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <416E8B7F.9050401@pobox.com>
References: <416BFD79.1010306@pobox.com>	<20041013.105243.511706221.takata.hirokazu@renesas.com>	<416C8E0B.4030409@pobox.com>	<20041013.121547.863739114.takata.hirokazu@renesas.com> <20041012223227.45a62301.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hirokazu Takata <takata.hirokazu@renesas.com>, takata@linux-m32r.org,
        linux-kernel@vger.kernel.org, paul.mundt@nokia.com, nico@cam.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20041012223227.45a62301.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> smc91x-revert-11923358-m32r-modify-drivers-net-smc91xc.patch
> smc91x-assorted-minor-cleanups.patch
> smc91x-set-the-mac-addr-from-the-smc_enable-function.patch
> smc91x-fold-smc_setmulticast-into-smc_set_multicast_list.patch
> smc91x-simplify-register-bank-usage.patch
> smc91x-move-tx-processing-out-of-irq-context-entirely.patch
> smc91x-use-a-work-queue-to-reconfigure-the-phy-from.patch
> smc91x-fix-possible-leak-of-the-skb-waiting-for-mem.patch
> smc91x-display-pertinent-register-values-from-the.patch
> smc91x-straighten-smp-locking.patch
> smc91x-cosmetics.patch
> m32r-trivial-fix-of-smc91xh.patch
> smc91x-fix-smp-lock-usage.patch
> smc91x-more-smp-locking-fixes.patch
> smc91x-fix-compilation-with-dma-on-pxa2xx.patch
> smc91x-receives-two-bytes-too-many.patch
> smc91x-release-on-chip-rx-packet-memory-asap.patch
> 
> I'll unload all those onto Jeff...


I'll wait for these patches, and drop other smc91x patches...

	Jeff
