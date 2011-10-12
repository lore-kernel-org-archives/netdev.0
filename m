From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] net-netlink: Add a new attribute to expose TOS
 values via netlink
Date: Wed, 12 Oct 2011 21:15:34 +0200
Message-ID: <1318446934.2644.0.camel@edumazet-laptop>
References: <20111012085235.3b78729b@nehalam.linuxnetplumber.net>
	 <1318446035-10267-1-git-send-email-muralira@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Muraliraja Muniraju <muralira@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318446035-10267-1-git-send-email-muralira@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 12 octobre 2011 =C3=A0 12:00 -0700, Muraliraja Muniraju a =C3=
=A9crit :
> From: Murali Raja <muralira@google.com>
>=20
> This patch exposes the tos value for the TCP sockets when the TOS fla=
g
> is requested in the ext_flags for the inet_diag request. This would m=
ainly be
> used to expose TOS values for both for TCP and UDP sockets. Currently=
 it is
> supported for TCP. When netlink support for UDP would be added the su=
pport
> to expose the TOS values would alse be done. For IPV4 tos value is ex=
posed
> and for IPV6 tclass value is exposed.
>=20
> Signed-off-by: Murali Raja <muralira@google.com>
> ---

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
