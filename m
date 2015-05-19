From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3] tcp: add rfc3168, section 6.1.1.1. fallback
Date: Tue, 19 May 2015 13:50:47 -0700
Message-ID: <1432068647.621.71.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cc0be24818d7009208dd0d8f73cc35939957f134.1432059419.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Mirja =?ISO-8859-1?Q?K=FChlewind?=
	<mirja.kuehlewind@tik.ee.ethz.ch>,
	Brian Trammell <trammell@tik.ee.ethz.ch>,
	Eric Dumazet <edumazet@google.com>,
	Dave =?ISO-8859-1?Q?T=E4ht?= <dave.taht@gmail.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:35202 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266AbbESUut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 16:50:49 -0400
Received: by igbyr2 with SMTP id yr2so86470593igb.0
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 13:50:49 -0700 (PDT)
In-Reply-To: <cc0be24818d7009208dd0d8f73cc35939957f134.1432059419.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-19 at 21:33 +0200, Daniel Borkmann wrote:
=2E..
>=20
> Reference: https://www.ietf.org/proceedings/92/slides/slides-92-iccrg=
-1.pdf
> Reference: https://www.ietf.org/proceedings/89/slides/slides-89-tsvar=
ea-1.pdf
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Mirja K=C3=BChlewind <mirja.kuehlewind@tik.ee.ethz.ch>
> Signed-off-by: Brian Trammell <trammell@tik.ee.ethz.ch>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Dave T=C3=A4ht <dave.taht@gmail.com>
> ---
>  v2 -> v3:
>   - Very sorry. Typo happened in Dave's name since v1, getting it rig=
ht
>     this time, no bad intentions. ;)
>  v1 -> v2:
>   - Added suggestion from Eric to let ecn_flags be cleared eventually=
 in
>     tcp_ecn_rcv_synack(), thanks!
>   - Rest as is.

Acked-by: Eric Dumazet <edumazet@google.com>
