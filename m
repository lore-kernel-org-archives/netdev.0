From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] dev: use name hash for dev_seq_ops
Date: Fri, 21 Oct 2011 08:52:53 +0200
Message-ID: <1319179973.2854.62.camel@edumazet-laptop>
References: <1319097717-14910-1-git-send-email-mmaruseac@ixiacom.com>
	 <1319179510-10715-1-git-send-email-mmaruseac@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, shemminger@vyatta.com,
	mirq-linux@rere.qmqm.pl, therbert@google.com, jpirko@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dbaluta@ixiacom.com, Mihai Maruseac <mmaruseac@ixiacom.com>
To: Mihai Maruseac <mihai.maruseac@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319179510-10715-1-git-send-email-mmaruseac@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 21 octobre 2011 =C3=A0 09:45 +0300, Mihai Maruseac a =C3=A9=
crit :
> Instead of using the dev->next chain and trying to resync at each cal=
l to
> dev_seq_start, use the name hash, keeping the bucket and the offset i=
n
> seq->private field.
>=20
=2E..
> Signed-off-by: Mihai Maruseac <mmaruseac@ixiacom.com>

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks
