From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Memory leak in ip_dst_cache
Date: Mon, 12 Sep 2011 19:57:52 +0200
Message-ID: <1315850272.2556.0.camel@edumazet-laptop>
References: <1315544674.20226.YahooMailNeo@web113902.mail.gq1.yahoo.com>
	 <1315546223.5410.23.camel@edumazet-laptop>
	 <1315593553.98279.YahooMailNeo@web113904.mail.gq1.yahoo.com>
	 <1315596786.2606.3.camel@edumazet-laptop>
	 <1315601283.91185.YahooMailNeo@web113908.mail.gq1.yahoo.com>
	 <1315604820.2606.13.camel@edumazet-laptop>
	 <1315605497.25052.YahooMailNeo@web113916.mail.gq1.yahoo.com>
	 <1315606125.2606.19.camel@edumazet-laptop>
	 <1315608825.98066.YahooMailNeo@web113914.mail.gq1.yahoo.com>
	 <20110910130416.GA2005@neilslaptop.think-freely.org>
	 <1315798710.96027.YahooMailNeo@web113913.mail.gq1.yahoo.com>
	 <1315806031.3174.16.camel@edumazet-laptop>
	 <1315807643.92529.YahooMailNeo@web113911.mail.gq1.yahoo.com>
	 <1315808931.3174.17.camel@edumazet-laptop>
	 <1315847801.41447.YahooMailNeo@web113916.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
To: Kumar S <ps2kumar@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55274 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400Ab1ILR55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2011 13:57:57 -0400
Received: by wwf22 with SMTP id 22so1726882wwf.1
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2011 10:57:56 -0700 (PDT)
In-Reply-To: <1315847801.41447.YahooMailNeo@web113916.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 12 septembre 2011 =C3=A0 10:16 -0700, Kumar S a =C3=A9crit :
> ----- Original Message -----
> From: Eric Dumazet <eric.dumazet@gmail.com>

> >What do you mean ? Your box is a router only ?
>=20
> >Those SMB messages are going through it ?
> =20
> Our box is a stand-alone system with L2 Quick Engine. This QE forward=
s
> all broadcast to the other ports and also a copy to the CPU port.=20

It sounds like a modified kernel, maybe you added a bug in the code...
