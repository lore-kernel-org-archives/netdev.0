From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: pulling net-netx git tree
Date: Fri, 09 Dec 2011 18:55:27 +0100
Message-ID: <1323453327.4016.0.camel@edumazet-laptop>
References: <CAGXs5wXc-dFs8uJXUpNpYUMs_rSwXV_r4zfWPSzkLPf0qxV-rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Kevin Wilson <wkevils@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:48242 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751156Ab1LIRzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2011 12:55:31 -0500
Received: by bkbzv3 with SMTP id zv3so3151540bkb.19
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2011 09:55:30 -0800 (PST)
In-Reply-To: <CAGXs5wXc-dFs8uJXUpNpYUMs_rSwXV_r4zfWPSzkLPf0qxV-rw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 09 d=C3=A9cembre 2011 =C3=A0 19:42 +0200, Kevin Wilson a =C3=
=A9crit :
> Hi,
>   I am trying to update my net-next tree, and I get
> git pull
>=20
> Already up-to-date.
>=20
> git log
> shows:
>=20
> commit 88c5100c28b02c4b2b2c6f6fafbbd76d90f698b9
> Merge: 8083f0f 3ee72ca
> Author: David S. Miller <davem@davemloft.net>
> Date:   Fri Oct 7 13:38:43 2011 -0400
>=20
>     Merge branch 'master' of github.com:davem330/net
>=20
> ...
> ...
>=20
> commit 8083f0fc969d9b5353061a7a6f963405057e26b1
> Author: Johannes Berg <johannes.berg@intel.com>
> Date:   Fri Oct 7 03:30:20 2011 +0000
>=20
> ...
> ...
>=20
>=20
> more .git/config
> shows
> url =3D https://github.com/davem330/net-next.git
>=20
>=20
> should I change this url ?  and if so - to what ?
>=20

David went back to :=20

http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next.git
