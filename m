From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround (fwd)
Date: Mon, 13 Oct 2008 15:32:49 -0300
Message-ID: <48f39456.060ec00a.1389.4433@mx.google.com>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>
	<48e3a4e5.0d1d640a.4cd3.06e9@mx.google.com>
	<alpine.LFD.1.10.0810012140360.5549@apollo.tec.linutronix.de>
	<48e3e835.0906c00a.2cd1.2fd1@mx.google.com>
	<alpine.LFD.1.10.0810021142370.5549@apollo.tec.linutronix.de>
	<48e4adb8.0807c00a.62b8.ffff87d6@mx.google.com>
	<alpine.LFD.1.10.0810021407400.5549@apollo.tec.linutronix.de>
	<48e4d63a.060ec00a.6a4e.ffff95bf@mx.google.com>
	<alpine.LFD.1.10.0810022113540.5549@apollo.tec.linutronix.de>
	<Pine.LNX.4.64.0810022251400.22964@wrl-59.cs.helsinki.fi>
	<48e5364d.0603c00a.6e25.fffff993@mx.google.com>
	<Pine.LNX.4.64.0810030008280.22964@wrl-59.cs.helsinki.fi>
	<48e8fef7.0610c00a.5fa2.ffffaab0@mx.google.com>
	<alpine.LFD.2.00.0810052008131.3398@apollo>
	<48ed0b51.0913c00a.7715.4aa7@mx.google.com>
	<alpine.LFD.2.00.0810082154420.3237@apollo>
	<48f2c9d7.0603c00a.1df2.ffff9357@mx.google.com>
	<Pine.LNX.4.64.0810131633370.3843@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Nicolas Cannasse <ncannasse@motion-twin.com>
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:44784 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755465AbYJMSc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 14:32:57 -0400
Received: by wa-out-1112.google.com with SMTP id v27so931663wah.21
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2008 11:32:56 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0810131633370.3843@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Oct 2008 16:35:08 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> http://marc.info/?t=3D122365716200001&r=3D1&w=3D2
>=20
> ...might turn out related. It has somewhat similar problem though=20
> different syscall. Not enough info on what kernel version etc.=20
> there though.

	Interesting. I CCed Nicolas Cannasse.

	Nicolas, could you please tell us what kernel version were you
using when you deal with this problem (from the link above: "recv()
hangs until SIGCHLD ?")?

	Thank you.

--=20
