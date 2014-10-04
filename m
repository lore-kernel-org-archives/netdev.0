From: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>
Subject: Re: [RFC 1/1] net: fix rcu access on phonet_routes
Date: Sat, 04 Oct 2014 14:24:47 +0300
Message-ID: <1511645.tJ3y45khDT@basile.remlab.net>
References: <1412416676-21698-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412416676-21698-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 4 octobre 2014, 11:57:56 Fabian Frederick a =C3=A9crit :
(snip)
> -Access table with rcu_dereference (fixes the following sparse errors=
):
> net/phonet/pn_dev.c:278:25: error: incompatible types in comparison
> expression (different address spaces) net/phonet/pn_dev.c:391:17: err=
or:
> incompatible types in comparison expression (different address spaces=
)

Acked-by: R=C3=A9mi Denis-Courmont <remi@remlab.net>

--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.net/
