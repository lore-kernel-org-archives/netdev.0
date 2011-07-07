From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: linux-next: Tree for July 7 (net/af_packet)
Date: Thu, 7 Jul 2011 13:06:51 -0400
Message-ID: <CAMjpGUfBL8wL_pBKWcfopOWFnZUG=u17LWjtECV6ubOVXn+vBQ@mail.gmail.com>
References: <20110707172544.867b980a1196db005b577c14@canb.auug.org.au>
 <20110707081202.6dddcbce.randy.dunlap@oracle.com> <20110707.081839.2119597618388053074.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: randy.dunlap@oracle.com, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110707.081839.2119597618388053074.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 7, 2011 at 11:18, David Miller wrote:
> packet: Fix build with INET disabled.
>
> af_packet.c:(.text+0x3d130): undefined reference to `ip_defrag'
> or
> ERROR: "ip_defrag" [net/packet/af_packet.ko] undefined!

fixes some Blackfin boards too.
Acked-by: Mike Frysinger <vapier@gentoo.org>
-mike
