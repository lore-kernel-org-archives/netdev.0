From: Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Tue, 1 May 2012 14:51:02 +0200
Message-ID: <20120501125102.GN3157@wantstofly.org>
References: <20120427094637.GV3157@wantstofly.org>
 <CA+icZUXNZ=exTnR=OgD_9bpt_0s-KnR+v-K6u+XzQr4HBoTQHQ@mail.gmail.com>
 <20120427095842.GW3157@wantstofly.org>
 <CA+icZUWuynSaPE4pdxzoP783pw7r=5x27ewXN_pkR5VS=0kKUg@mail.gmail.com>
 <20120427101732.GX3157@wantstofly.org>
 <CA+icZUUnJPeDmL9xXfvj62an40bXwwaOnrJmxmLN_cBt9PyCZA@mail.gmail.com>
 <CA+icZUV76wSBj88EpzmWbO=u2dP23yi5P98nN2KZehBUni9mEg@mail.gmail.com>
 <20120427185809.GZ3157@wantstofly.org>
 <CA+icZUWQmCRdjucb4+Nf24_zbJ4fzzp7zjqhKjXE6U01rppDfA@mail.gmail.com>
 <CA+icZUXSaEMA=KbQP9UQcU6ZMBh8QD2sv-O=6r_Ly8is==gvSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lautriv <admin-kieEQ4o6Pv7k1uMJSBkQmQ@public.gmane.org>,
	Jim Cromie <jim.cromie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CA+icZUXSaEMA=KbQP9UQcU6ZMBh8QD2sv-O=6r_Ly8is==gvSA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 29, 2012 at 12:25:21AM +0200, Sedat Dilek wrote:

> > On 1st sight, logs look fine:
> >
> > [21:52:52] <lautriv> [ =A0 =A06.050967] ieee80211 phy0: 88w8361p v4=
,
> > 00173f3bdde3, STA firmware 2.1.4.25
> >
> > But WLAN connection is not that fast and stable as lautriv reports
> > (several abnormalities were observed).
> >
> > I requested a tarball which includes:
> > * dmesg (Linux-3.3.3)
> > * e_n_a (/etc/network/interfaces)
> > * ifconfig output
> > * iwconfig output
> > * iw_phy output
> > * ps_axu (WPA) output
> >
> > lautriv will be so kind to be around on #linux-wireless/Freenode th=
e
> > next days (UTC+2: German/Swiss local-time).
> > Just ping him.
> >
> > Hope you have fun, together!
> >
> > - Sedat -
>=20
> A new tarball from lautriv with same outputs as before, but now teste=
d
> with Linux-3.4-rc4.

The output looks good enough for me to ACK adding the PCI ID.

Can the firmware being used here be submitted to the linux-firmware
git tree?
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
