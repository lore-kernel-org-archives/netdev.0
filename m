From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Squid hang up on 2.6.34
Date: Fri, 09 Jul 2010 00:08:41 +0200
Message-ID: <1278626921.2435.73.camel@edumazet-laptop>
References: <AANLkTimn8A0cYZmwNZYitRkBHKKFe4HQ5GU626DLugkk@mail.gmail.com>
	 <AANLkTil49m6Ul2bauiH4Pwn-6ykrYTFmSO6_SxqQgD_e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Felipe W Damasio <felipewd@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48880 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753732Ab0GHWP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 18:15:27 -0400
In-Reply-To: <AANLkTil49m6Ul2bauiH4Pwn-6ykrYTFmSO6_SxqQgD_e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 08 juillet 2010 =C3=A0 18:30 -0300, Felipe W Damasio a =C3=A9c=
rit :
> Hi again,
>=20
> Just FYI: After squid hung up, I started it again.
>=20
> A few minutes later, the machine frooze...after a reboot, syslog
> didn't show any messages.
>=20
> So the message below is the only tip of what happened.
>=20
> Cheers,

Please try to reproduce a new report.

It looks like a memory corruption, and it would be good to see if a
common pattern is occurring.


