From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8139cp: enable bql
Date: Sun, 25 Nov 2012 15:55:29 -0500 (EST)
Message-ID: <20121125.155529.142681105479432173.davem@davemloft.net>
References: <1353590218.26346.214.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, codel@lists.bufferbloat.net
To: dwmw2@infradead.org
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <1353590218.26346.214.camel@shinybook.infradead.org>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

From: David Woodhouse <dwmw2@infradead.org>
Date: Thu, 22 Nov 2012 13:16:58 +0000

> This adds support for byte queue limits on RTL8139C+
> =

> Tested on real hardware.
> =

> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
> Acked-By: Dave T=E4ht <dave.taht@bufferbloat.net>

Applied to net-next.

> --- drivers/net/ethernet/realtek/8139cp.c~	2012-11-21 20:49:47.000000000 =
+0000
> +++ drivers/net/ethernet/realtek/8139cp.c	2012-11-22 13:07:26.119076315 +=
0000

Please "-p1" root your patches in the future.
