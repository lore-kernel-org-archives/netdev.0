From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.38.2, kernel panic, probably related to framentation
 handling
Date: Wed, 04 May 2011 20:11:14 +0200
Message-ID: <1304532674.32152.16.camel@edumazet-laptop>
References: <f2c5863250c7a5fb11a189759bd736cf@visp.net.lb>
	 <1304528581.32152.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43045 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754929Ab1EDSLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 14:11:19 -0400
Received: by wya21 with SMTP id 21so1048395wya.19
        for <netdev@vger.kernel.org>; Wed, 04 May 2011 11:11:18 -0700 (PDT)
In-Reply-To: <1304528581.32152.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 04 mai 2011 =C3=A0 19:03 +0200, Eric Dumazet a =C3=A9crit :

> Hi Denys
>=20
> Is it reproductible, and possibly on latest kernel ?
>=20
> We fixed some bugs lately (assuming you also use a bridge ?)
>=20
> Could you send the disassembled code on your kernel of icmp_send() ?

Oh well, I think I found the problem, I am working on a patch and send
it shortly.

Thanks


