From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Expose the initial RTO via a new sysctl.
Date: Tue, 17 May 2011 10:34:01 +0200
Message-ID: <1305621241.2850.18.camel@edumazet-laptop>
References: <1305618020-72535-1-git-send-email-tsunanet@gmail.com>
	 <1305618020-72535-2-git-send-email-tsunanet@gmail.com>
	 <E5F8880D-72DF-488B-9515-60453D3EC240@comsys.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benoit Sigoure <tsunanet@gmail.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <E5F8880D-72DF-488B-9515-60453D3EC240@comsys.rwth-aachen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 17 mai 2011 =C3=A0 10:01 +0200, Alexander Zimmermann a =C3=A9c=
rit :

>=20
> regardless of netdev will accept this patch or not, the
> upcoming initRTO is 1s. See
> http://tools.ietf.org/id/draft-paxson-tcpm-rfc2988bis-02.txt
>=20
> The draft is IESG approved and will become an RFC soon.

Thanks Alex for this link / information.
