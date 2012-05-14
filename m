From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next] net/codel: Add missing #include
 <linux/prefetch.h>
Date: Mon, 14 May 2012 23:04:58 +0200
Message-ID: <1337029498.8512.624.camel@edumazet-glaptop>
References: <1337024825-20130-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>,
	Dave Taht <dave.taht@bufferbloat.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337024825-20130-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-05-14 at 21:47 +0200, Geert Uytterhoeven wrote:
> m68k allmodconfig:
>=20
> net/sched/sch_codel.c: In function =E2=80=98dequeue=E2=80=99:
> net/sched/sch_codel.c:70: error: implicit declaration of function =E2=
=80=98prefetch=E2=80=99
> make[1]: *** [net/sched/sch_codel.o] Error 1
>=20
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---

I plaid guilty

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks
