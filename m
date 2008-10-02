From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround (fwd)
Date: Thu, 2 Oct 2008 17:59:52 -0300
Message-ID: <48e5364d.0603c00a.6e25.fffff993@mx.google.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:11385 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754153AbYJBVAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 17:00:00 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1327787rvb.1
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2008 14:00:00 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0810022251400.22964@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2 Oct 2008 23:31:28 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> Ah, I was kind of thinking that you were doing something net related=20
> using some raw socket thing (such as traceroute) when you earlier=20
> mentioned sudo (iirc, we never really discussed what you usually do w=
ith=20
> it when you see the stall).

	I read nntp groups everyday and I use leafnode. The stall on my
desktop happens when I run fetchnews (which must be run as user "news"
so I have to use sudo). Usually the stall on my desktop happens when
I'm using fetchnews or some other command run by sudo.

> We might have had a change if there would have been a (failed) connec=
tion=20
> attempt in it but there seemed to be none.

	Ok, I'll wait for the breakpoint in the patch Thomas provided.
Now we need just a bit of patience ;).

	Thanks everybody.


--=20
