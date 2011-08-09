From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch] scm: Capture the full credentials of the scm sender
Date: Tue, 09 Aug 2011 20:12:15 +0200
Message-ID: <1312913535.2547.6.camel@edumazet-laptop>
References: <1312841316.2576.49.camel@schen9-DESK>
	 <1312857834.2531.15.camel@edumazet-laptop>
	 <1312908512.2576.97.camel@schen9-DESK>  <4E41772D.1070700@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tim Chen <tim.c.chen@linux.intel.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andi Kleen <ak@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E41772D.1070700@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 09 ao=C3=BBt 2011 =C3=A0 11:06 -0700, Andi Kleen a =C3=A9crit =
:
> > This patch corrects an erroneous update of credential's gid with ui=
d
> > introduced in commit 257b5358b32f17 since 2.6.36.
>=20
>=20
> Please also add a Cc: stable@kernel.org
>=20

David handles stable submission himself, a priori.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
