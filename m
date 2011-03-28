From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Handle gso packets in dev_forward_skb
Date: Mon, 28 Mar 2011 21:20:48 +0200
Message-ID: <1301340048.2506.13.camel@edumazet-laptop>
References: <m1wrjsi2tf.fsf@fess.ebiederm.org>
	 <1300743744.2837.7.camel@edumazet-laptop>
	 <m1hbawi15z.fsf@fess.ebiederm.org>
	 <20110327.180922.59673799.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	greearb@candelatech.com, arnd@arndb.de, kaber@trash.net,
	Daniel Lezcano <daniel.lezcano@free.fr>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38403 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089Ab1C1TUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 15:20:54 -0400
Received: by fxm17 with SMTP id 17so2932416fxm.19
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2011 12:20:53 -0700 (PDT)
In-Reply-To: <20110327.180922.59673799.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 27 mars 2011 =C3=A0 18:09 -0700, David Miller a =C3=A9crit =
:
> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Mon, 21 Mar 2011 15:00:56 -0700
>=20
> > Eric Dumazet <eric.dumazet@gmail.com> writes:
> >=20
> >> Hmm, did you follow http://patchwork.ozlabs.org/patch/86815/
> >> discussion ?
> >=20
> > No.  It seems I missed it, but I do have the same problem, and
> > essentially the same fix.=20
>=20
> Can someone work on getting this straightened out and resubmit the
> final patch so I can apply something?
>=20

Apparently Daniel is busy.

I guess we can use Eric B. patch, then ?



