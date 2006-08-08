From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.18-rc3-mm2: bad e1000 device name
Date: Tue, 8 Aug 2006 00:40:11 -0700
Message-ID: <20060808004011.ab3cd65f.akpm@osdl.org>
References: <44D78A48.7050707@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:30189 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932528AbWHHHkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 03:40:16 -0400
To: Jeremy Fitzhardinge <jeremy@goop.org>
In-Reply-To: <44D78A48.7050707@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 07 Aug 2006 11:45:28 -0700
Jeremy Fitzhardinge <jeremy@goop.org> wrote:

> With 2.6.18-rc3-mm2, I get a bogus device name for my e1000 device,=20
> which I would expect to be eth0:
>=20
> : ezr:pts/0; ifconfig -a
> =EF=BF=BD6f=EF=BF=BD      Link encap:Ethernet  HWaddr 00:16:D3:20:D2:=
0B =20
>           UP BROADCAST MULTICAST  MTU:1500  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000=20
>           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
>           Base address:0x2000 Memory:ee000000-ee020000=20
> [...]

e1000 seems OK here.  Don't know, sorry.
