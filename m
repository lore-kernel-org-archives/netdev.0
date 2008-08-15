From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Fri, 15 Aug 2008 20:57:59 -0300
Message-ID: <20080815205759.12f64aad@tux>
References: <Pine.LNX.4.64.0808081256560.4551@wrl-59.cs.helsinki.fi>
	<20080811.144421.234396007.davem@davemloft.net>
	<200808120946.19459.thomas.jarosch@intra2net.com>
	<20080812.011822.155249871.davem@davemloft.net>
	<20080812144309.7d62fd86@tux>
	<Pine.LNX.4.64.0808122044450.16105@wrl-59.cs.helsinki.fi>
	<20080813145310.0c1e534c@tux>
	<Pine.LNX.4.64.0808132108480.18807@wrl-59.cs.helsinki.fi>
	<20080815013407.4a594288@tux>
	<Pine.LNX.4.64.0808150939270.23522@wrl-59.cs.helsinki.fi>
	<20080815183511.1c81be23@tux>
	<Pine.LNX.4.64.0808160039230.6911@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>, sr@securenet.de,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:26743 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958AbYHOX6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 19:58:08 -0400
Received: by yx-out-2324.google.com with SMTP id 8so893179yxm.1
        for <netdev@vger.kernel.org>; Fri, 15 Aug 2008 16:58:07 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0808160039230.6911@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 16 Aug 2008 01:06:55 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> You might have mentioned it but I would like you to confirm which ker=
nel=20
> version the server is running (at least 2.6.25.7 or 2.6.26 is new eno=
ugh=20
> to have all bug fixes)?

	Yes, 2.6.26.=20

	Thank you very much for your excellent explanation. You helped
a lot. I'll try to do my "home work" and as soon as I have the data,
I'll return.


--=20
