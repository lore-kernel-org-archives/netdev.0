From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] ip: fix truesize mismatch in ip fragmentation
Date: Tue, 21 Sep 2010 18:31:19 +0200
Message-ID: <1285086679.2617.672.camel@edumazet-laptop>
References: <20100920174443.GA5515@elliptictech.com>
	 <1285006844.2323.17.camel@edumazet-laptop>
	 <20100920195256.GA14330@elliptictech.com>
	 <1285013853.2323.148.camel@edumazet-laptop>
	 <1285018272.2323.243.camel@edumazet-laptop>
	 <20100921140501.GA21572@elliptictech.com>
	 <1285078613.2617.503.camel@edumazet-laptop>
	 <1285084705.2617.636.camel@edumazet-laptop>
	 <20100921162657.GA22183@khazad-dum.debian.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nick Bowler <nbowler@elliptictech.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55061 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754599Ab0IUQbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 12:31:24 -0400
In-Reply-To: <20100921162657.GA22183@khazad-dum.debian.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 septembre 2010 =C3=A0 13:26 -0300, Henrique de Moraes Holsc=
huh a
=C3=A9crit :
> Should this be a candidate for -stable?
>=20

Yes, of course, but David wants to handle stable submissions himself.

I am not sure we want to bug stable team with dozens of mails while
polishing patches ?

Thanks


