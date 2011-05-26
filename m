From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [ANNOUNCE]: Release of iptables-1.4.11
Date: Thu, 26 May 2011 22:16:46 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1105262210410.30203@frira.zrqbmnf.qr>
References: <4DDE857E.40807@trash.net> <1306434537.2543.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, NetDev <netdev@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org,
	"'netfilter@vger.kernel.org'" <netfilter@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([188.40.89.202]:39605 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752321Ab1EZUQr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2011 16:16:47 -0400
In-Reply-To: <1306434537.2543.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 2011-05-26 20:28, Eric Dumazet wrote:

>Le jeudi 26 mai 2011 =C3=A0 18:53 +0200, Patrick McHardy a =C3=A9crit =
:
>> The netfilter coreteam presents:
>>=20
>>     iptables version 1.4.10
>>=20
>> the iptables release for the 2.6.39 kernels. Due to some mistakes
>> on my side we didn't have a release for longer than expected, so
>> this contains a rather large number of changes.
>>=20
>> Changes include:
>>=20
>
>...
>> - a new iptables option "-C" to check for existance of a rules
>
>Nice, but this still loads modules...

So does iptables -S (and -L).  :)

