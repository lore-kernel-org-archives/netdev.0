From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] should we care of COMPAT mode in bridge ?
Date: Mon, 06 Jun 2011 22:34:03 +0200
Message-ID: <1307392443.2642.17.camel@edumazet-laptop>
References: <1307389540.2642.3.camel@edumazet-laptop>
	 <20110606.130309.847468074358617705.davem@davemloft.net>
	 <m28vtevgzo.fsf@igel.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andreas Schwab <schwab@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46629 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757354Ab1FFUeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 16:34:10 -0400
Received: by wwa36 with SMTP id 36so4209009wwa.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 13:34:09 -0700 (PDT)
In-Reply-To: <m28vtevgzo.fsf@igel.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 juin 2011 =C3=A0 22:31 +0200, Andreas Schwab a =C3=A9crit :

> OTOH, the SIOCSIFBR and SIOCGIFBR ioctls are obsoleted by the
> SIOCBRADDBR, SIOCBRDELBR, SIOCBRADDIF, SIOCBRDELIF ioctls and bridge
> sysfs files (which have no compat issues).
>=20

Yep, unless you are stuck with an old binary :)




