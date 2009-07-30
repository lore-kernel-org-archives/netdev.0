From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 0/4] au1000_eth platform device/driver conversion
Date: Thu, 30 Jul 2009 22:13:59 +0200
Message-ID: <200907302214.00525.florian@openwrt.org>
References: <200907282300.07144.florian@openwrt.org> <4A71F8FD.3060002@ru.mvista.com> <20090730.131000.259116391.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sshtylyov@ru.mvista.com, ralf@linux-mips.org,
	manuel.lauss@googlemail.com, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:64465 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967AbZG3UOK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 16:14:10 -0400
Received: by ewy10 with SMTP id 10so1051184ewy.37
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2009 13:14:10 -0700 (PDT)
In-Reply-To: <20090730.131000.259116391.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Le Thursday 30 July 2009 22:10:00 David Miller, vous avez =E9crit=A0:
> From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
> Date: Thu, 30 Jul 2009 23:48:13 +0400
>
> >   Because they were only posted to linux-mips. And we didn't see #2=
 and
> >   #4 in linux-mips either.
>
> That's not going to work.
>
> You can't apply some of these patches to one tree, and some to
> the other.  That leaves the driver in a half-baked state in BOTH
> trees during the entire development period.

Sorry about that I did not want to "spam" netdev with MIPS specific bit=
s as I=20
know those specific changes would lead to a discussion for sure.

>
> So one of the two trees has to be chosen and all 4 patches added
> there, and there only.

Ok, I got to respin them to address some comments on the MIPS-side anyw=
ay and=20
will not forget to CC netdev and you this time.
--=20
Best regards, Florian Fainelli
Email: florian@openwrt.org
Web: http://openwrt.org
IRC: [florian] on irc.freenode.net
-------------------------------
