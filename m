From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH net-next] asix: asix_rx_fixup surgery to reduce skb
 truesizes
Date: Thu, 15 Mar 2012 04:49:45 -0700
Message-ID: <1331812185.2543.25.camel@edumazet-laptop>
References: <1331792312.2543.16.camel@edumazet-laptop>
	 <CANEJEGtndncj1biMZSBC1rt36a66iWGp7wU_OxCxpA_PVBGZqA@mail.gmail.com>
	 <001401cd029f$999ab140$ccd013c0$@com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: 'Grant Grundler' <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	'Greg Kroah-Hartman' <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	'David Miller' <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, 'netdev' <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	'Aurelien Jacobs' <aurel-U/apLSaFET4dnm+yROfE0A@public.gmane.org>,
	'Trond Wuellner' <trond-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	'Paul Stewart' <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
To: "ASIX Allan Email [office]" <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <001401cd029f$999ab140$ccd013c0$@com.tw>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le jeudi 15 mars 2012 =C3=A0 19:34 +0800, ASIX Allan Email [office] a =C3=
=A9crit :
> Dear Grant and All,
>=20
> We are going to do some testing on the revised asix.c driver with
> ASIX's different USB to LAN solutions
> (AX88178/AX88772B/AX88772A/AX88772). Please advise where can I
> download the latest revised asix.c driver source with this driver
> patch for further testing? (Sorry I am newbie on Linux kernel driver
> patch threads. =3D_=3D"") Thanks a lot.
>=20
Hi Allan

I based this patch on net-next tree, the official network 'next' tree
maintained by David Miller, available here :

http://git2.kernel.org/?p=3Dlinux/kernel/git/davem/net-next.git;a=3Dsum=
mary

Does it answer to your question ?


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
