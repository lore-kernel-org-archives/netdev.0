From: Oliver Neukum <oliver@neukum.org>
Subject: Re: No networking since git3
Date: Sat, 19 Mar 2011 16:31:07 +0100
Message-ID: <201103191631.07952.oliver@neukum.org>
References: <4D84A46B.1000407@example.com> <AANLkTimFGeHYEOxx=h883rRJL463g1CBUDS0wGM-52Nj@mail.gmail.com> <1300547930.2831.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Anca Emanuel <anca.emanuel@gmail.com>, piotr@hosowicz.com,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300547930.2831.27.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Samstag, 19. M=C3=A4rz 2011, 16:18:50 schrieb Eric Dumazet:

> Problem comes from commit 54405cde762408b00a445466a40da4f7f33a8479
> (r8169: support control of advertising.)
>=20
> Reverting it brings back NIC for me

Odd. It worked for me. Are you testing on a gigabit switch? Could you s=
end
me dmesg? Does it work if you use ethtool to advertise a lower speed?

	Regards
		Oliver
