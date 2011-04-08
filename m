From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 32832] New: shutdown(2) does not fully shut down socket
 any more
Date: Fri, 08 Apr 2011 23:03:53 +0200
Message-ID: <1302296633.2656.79.camel@edumazet-laptop>
References: <20110406160713.7ff48ef1@nehalam>
	 <20110406.164805.193714589.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59640 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753401Ab1DHVD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 17:03:59 -0400
Received: by wwa36 with SMTP id 36so4683644wwa.1
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2011 14:03:58 -0700 (PDT)
In-Reply-To: <20110406.164805.193714589.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 06 avril 2011 =C3=A0 16:48 -0700, David Miller a =C3=A9crit=
 :
> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Wed, 6 Apr 2011 16:07:13 -0700
>=20
> > Begin forwarded message:
> >=20
> > Date: Wed, 6 Apr 2011 22:42:39 GMT
> > From: bugzilla-daemon@bugzilla.kernel.org
> > To: shemminger@linux-foundation.org
> > Subject: [Bug 32832] New: shutdown(2) does not fully shut down sock=
et any more
> >=20
> >=20
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D32832
> >=20
> >            Summary: shutdown(2) does not fully shut down socket any=
 more
>  ...
> >=20
> > In 2.6.35 and earlier, shutdown(2) will fully remove a socket. This=
 does not
> > appear to be true any more and is causing software to misbehave.
> >=20
>=20
> This is already being discussed:
>=20
> http://marc.info/?l=3Dlinux-netdev&m=3D130176733401613&w=3D2


Status update : I'll take time this week end to work on this and find a
solution.

Thanks


