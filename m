From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Sun, 10 Feb 2013 19:07:33 -0500 (EST)
Message-ID: <20130210.190733.2188067351706209540.davem@davemloft.net>
References: <20130208.151713.1708597749091717933.davem@davemloft.net>
	<CA+55aFx81-GGEEXx+MqJvwJsDoBMMqSN80=J8LmN-Ufu4+kKcw@mail.gmail.com>
	<20130208225026.GA24672@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	hayeswang@realtek.com, jrg.otte@gmail.com
To: romieu@fr.zoreil.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130208225026.GA24672@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 8 Feb 2013 23:50:26 +0100

> Linus Torvalds <torvalds@linux-foundation.org> :
> [...]
>> However, there's still the r8169 regressions (see the emails with th=
e
>> subject "regression: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0
>> timed out"). It's bisected, and a revert is reported to fix things.
>> It's not in this pull request. Comments ?
>=20
> J=F6rg asked Hayes. Hayes suggested to revert. Francois reverts, fixe=
s a
> pair of rejects, builds, boot. Anyone should be able to pull from
> branch 'davem.r8169' in repository
>=20
> git://violet.fr.zoreil.com/romieu/linux davem.r8169

Now that J=F6rg has tested these reverts successfully, I've pulled
them into my tree, thanks everyone.
