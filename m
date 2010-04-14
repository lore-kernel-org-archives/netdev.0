From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fix potential wild pointer when NIC is dying
Date: Wed, 14 Apr 2010 09:49:08 +0200
Message-ID: <1271231348.16881.631.camel@edumazet-laptop>
References: <1271247503-2973-1-git-send-email-xiaosuo@gmail.com>
	 <1271223212.16881.598.camel@edumazet-laptop>
	 <u2r412e6f7f1004140025i51e533c9t7402bc751dd925c2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:32925 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851Ab0DNHtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 03:49:14 -0400
Received: by bwz25 with SMTP id 25so6468528bwz.28
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 00:49:13 -0700 (PDT)
In-Reply-To: <u2r412e6f7f1004140025i51e533c9t7402bc751dd925c2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 avril 2010 =C3=A0 15:25 +0800, Changli Gao a =C3=A9crit =
:

>=20
> Thanks, I got it.
>=20

No problem, its better to double check anyway :)



