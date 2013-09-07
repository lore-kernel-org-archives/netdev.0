From: =?UTF-8?B?RnLDqWTDqXJpYyBMZXJveQ==?= <fredo@starox.org>
Subject: Re: Realtek r8168 hangs when sending data at full speed on a gigabit
 link
Date: Sat, 07 Sep 2013 21:35:32 +0200
Message-ID: <522B8004.5060701@starox.org>
References: <5221C226.9040209@starox.org> <20130901213610.GA25211@electric-eye.fr.zoreil.com> <52245E82.5020004@starox.org> <20130907101546.GA19560@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	David R <david@unsolicited.net>,
	Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-34071.dedibox.fr ([88.191.154.35]:34408 "EHLO
	sd-34071.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684Ab3IGTfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 15:35:42 -0400
In-Reply-To: <20130907101546.GA19560@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Le 07/09/2013 12:15, Francois Romieu a =C3=A9crit :
> Fr=C3=A9d=C3=A9ric Leroy <fredo@starox.org> :
> [...]
>
> Sorry for the delay. It was a busy week.
>
> Can you give the hack below a try ?

I tested it with and without.
The patch works perfectly ! Thanks :)

--=20
=46r=C3=A9d=C3=A9ric
