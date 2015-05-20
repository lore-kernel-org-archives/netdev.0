From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3] tcp: add rfc3168, section 6.1.1.1. fallback
Date: Wed, 20 May 2015 11:37:36 -0700
Message-ID: <1432147056.4060.35.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cc0be24818d7009208dd0d8f73cc35939957f134.1432059419.git.daniel@iogearbox.net>
	 <20150519.165400.818177627516799715.davem@davemloft.net>
	 <CAGK4HS_U5Me2ubi-QPaceLiw-ZU7P9Q=ZOSpgg6SRqn-fA2Gaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	netdev <netdev@vger.kernel.org>, fw@strlen.de,
	mirja.kuehlewind@tik.ee.ethz.ch, trammell@tik.ee.ethz.ch,
	Eric Dumazet <edumazet@google.com>,
	Dave Taht <dave.taht@gmail.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:33593 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753910AbbETShi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 14:37:38 -0400
Received: by igbpi8 with SMTP id pi8so141714239igb.0
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 11:37:38 -0700 (PDT)
In-Reply-To: <CAGK4HS_U5Me2ubi-QPaceLiw-ZU7P9Q=ZOSpgg6SRqn-fA2Gaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-20 at 11:13 -0700, Vijay Subramanian wrote:
> Hi Daniel,
> 
> With this commit, ifconfig does not show any of the interfaces and I
> don't have any connectivity as a result.
> Can you double check this?

Please do not top post.

No problem here. I do not see obvious reasons for breaking your setup.
