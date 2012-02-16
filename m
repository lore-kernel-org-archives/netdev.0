From: joeyli <jlee@suse.com>
Subject: Re: Bogus frames transmitted with r8169 & fragmentation & large mtu
Date: Thu, 16 Feb 2012 18:15:55 +0800
Message-ID: <1329387355.5525.49.camel@linux-s257.site>
References: <20120215163748.GA3998@elliptictech.com>
	 <20120215224122.GA31463@electric-eye.fr.zoreil.com>
	 <20120215233408.GA8389@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Nick Bowler <nbowler@elliptictech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:48430 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884Ab2BPKQo (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:0:0>);
	Thu, 16 Feb 2012 05:16:44 -0500
In-Reply-To: <20120215233408.GA8389@elliptictech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nick,=20

=E6=96=BC =E4=B8=89=EF=BC=8C2012-02-15 =E6=96=BC 18:34 -0500=EF=BC=8CNi=
ck Bowler =E6=8F=90=E5=88=B0=EF=BC=9A
> On 2012-02-15 23:41 +0100, Francois Romieu wrote:
> > Nick Bowler <nbowler@elliptictech.com> :
> > [...]
> > > Let me know if you need any more info,
> >=20
> > Please send the XID line from the r8169 driver for this device.
>=20
> This one?
>=20
>   [   10.344571] r8169 0000:02:00.0: eth0: RTL8168d/8111d at 0xf80640=
00, bc:ae:c5:27:19:6f, XID 083000c0 IRQ 41
>=20

Did you see any message from r8169 in dmesg said lost firmware file on
your system?


Thanks
Joey Lee
