From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Sat, 2 Aug 2008 09:24:55 -0300
Message-ID: <20080802092455.4e6a8b84@tux>
References: <47EA0DAB.7080205@securenet.de>
	<200807111633.42514.thomas.jarosch@intra2net.com>
	<200807151347.23598.thomas.jarosch@intra2net.com>
	<200807151810.45942.thomas.jarosch@intra2net.com>
	<20080715153045.12efaea4@tux>
	<55u7m5-i63.ln1@tux.abusar.org.br>
	<Pine.LNX.4.64.0807311035350.4551@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:41225 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520AbYHBMZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2008 08:25:00 -0400
Received: by yw-out-2324.google.com with SMTP id 9so831956ywe.1
        for <netdev@vger.kernel.org>; Sat, 02 Aug 2008 05:24:59 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0807311035350.4551@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 31 Jul 2008 10:39:56 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> Tcpdumping it would help some... :-) Can you try the suggested patch =
if it=20
> changes any (though would I have a tcpdump showing the problem, I cou=
ld=20
> probably tell right away if the patch would help or not, and also com=
e up=20
> with something else if necessary :-)):
>=20
>   http://marc.info/?l=3Dlinux-netdev&m=3D121699478406378&w=3D2

	Hi, I'm using the patch and I can confirm it solved my problem.
No more stalled connections :).

	Is there any chance this patch can be merged in the kernel?
Thank you.

--=20


--=20
