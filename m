From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH net-next v3] tcp: add rfc3168, section 6.1.1.1. fallback
Date: Thu, 21 May 2015 11:10:37 -0700
Message-ID: <CAGK4HS8s=CHRY_Zv=THv22PemkHx-acVFVTDSj1PFUfr8sj4Vw@mail.gmail.com>
References: <cc0be24818d7009208dd0d8f73cc35939957f134.1432059419.git.daniel@iogearbox.net>
	<20150519.165400.818177627516799715.davem@davemloft.net>
	<CAGK4HS_U5Me2ubi-QPaceLiw-ZU7P9Q=ZOSpgg6SRqn-fA2Gaw@mail.gmail.com>
	<1432147056.4060.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	netdev <netdev@vger.kernel.org>, fw@strlen.de,
	mirja.kuehlewind@tik.ee.ethz.ch, trammell@tik.ee.ethz.ch,
	Eric Dumazet <edumazet@google.com>,
	Dave Taht <dave.taht@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f180.google.com ([209.85.160.180]:35728 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088AbbEUSKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 14:10:38 -0400
Received: by ykec202 with SMTP id c202so28682314yke.2
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 11:10:37 -0700 (PDT)
In-Reply-To: <1432147056.4060.35.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Please do not top post.

My fault. Will be more careful in future.

>
> No problem here. I do not see obvious reasons for breaking your setup.
>

It was a problem with my network driver not getting installed due to
some symbol mismatch after a compile. It got sorted out after I
cleaned up everything. This was a false alarm. Apologies for the
noise.

Vijay
