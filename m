From: "Jean-Baptiste Vignaud" <vignaud@xandmail.fr>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Tue, 26 Jun 2007 16:24:07 +0200
Message-ID: <JK8YO7$ED15496EC345D64436196D8FF32F355E@xandmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "jarkao2" <jarkao2@o2.pl>,
	"marcin\.slusarz" <marcin.slusarz@gmail.com>,
	"shemminger" <shemminger@linux-foundation.org>,
	"linux-net" <linux-net@vger.kernel.org>,
	"netdev" <netdev@vger.kernel.org>
To: "linux-kernel" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.xandmail.com ([212.155.184.97]:41551 "EHLO
	mail.xandmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756500AbXFZPLa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2007 11:11:30 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, i have a very similar problem with 2.6.21 also;

2 3com NICs and they are failling randomly.

The kernel is a basic fedora 7 kernel (2.6.21-1.3228.fc7)
I found a bug report and added details here : https://bugzilla.redhat.c=
om/bugzilla/show_bug.cgi?id=3D243960

I'm not subcribed on this list, so please cc me if there is any questio=
ns.

JB

> On Tue, Jun 26, 2007 at 08:10:17AM +0200, Marcin =C5=9Alusarz wrote:
> ...=20
> > I reproduced it on minimal config:
> ...
>=20
> Hm... This method is usable if you can find such minimal config
> with which the bug cannot be reproduced. Then you can add more
> until the bug is back. Of course, this takes time...
>=20
> We know your hardware should be OK - since it was fine with 2.6.20.
> We don't know how much your configs (kernel & apps) have changed.
> Sometimes the change of kernel needs some apps to be recompiled too.
> That's why it could be usable to try 2.6.21 from a live distro to
> find if it's really kernel's fault.
>=20
> And, alas, this log doesn't seem to tell nothing new...
>=20
> Regards,
> Jarek P.
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>=20
>=20
>=20

