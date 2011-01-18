From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek r8168C / r8169 driver VLAN TAG stripping
Date: Tue, 18 Jan 2011 02:21:46 +0100
Message-ID: <20110118012146.GA3704@electric-eye.fr.zoreil.com>
References: <AANLkTi=qVSEh=RyzJ6y4kQvJW+hxqWMh2gAMmhk7GGob@mail.gmail.com> <AANLkTimqkJ3DGBX5iREEcx6sgAM+2CZHNWMU+noNSitp@mail.gmail.com> <20110116192017.GA3569@electric-eye.fr.zoreil.com> <AANLkTi=uNKMj_gs_bKRQ1tQa0TMwdnyrtVcR5JPNpmJv@mail.gmail.com> <AANLkTikoXfgHrJyMbe6A_HmvXT_QRo55w76st5Wo0hSv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Hayes <hayeswang@realtek.com>
To: Anand Raj Manickam <anandrm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39561 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751659Ab1ARBWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 20:22:47 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTikoXfgHrJyMbe6A_HmvXT_QRo55w76st5Wo0hSv@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anand Raj Manickam <anandrm@gmail.com> :
> On Mon, Jan 17, 2011 at 11:52 AM, Anand Raj Manickam <anandrm@gmail.c=
om> wrote:
[...]
> > This is the dmesg =C2=A0for XID
> >
> > eth0: RTL8168c/8111c at 0xf9628000, 00:17:54:00:f6:62, XID 1c4000c0=
 IRQ 31
> > r8169: mac_version =3D 0x16

I do not have one of those (RTL_GIGA_MAC_VER_22) to check if it handles=
 vlan
correctly yet.

> > r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> >
> > Unfortunately , i m not able to upgrade my kernel now . If there is=
 a
> > Fix for it , that would be great !!

I doubt there is a lot of glamour/fortune/fame in backporting the 89 r8=
169
patches between v2.6.30 and v2.6.37 but you may help yourself and give =
it
a try.

--=20
Ueimor
