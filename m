From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: accurate bytes/packets stats/rates
Date: Mon, 17 Jan 2011 07:54:55 +0100
Message-ID: <1295247295.12859.9.camel@edumazet-laptop>
References: <1295021808.3937.110.camel@edumazet-laptop>
	 <20110114095201.4fc58a45@nehalam>
	 <1295028502.3937.116.camel@edumazet-laptop>
	 <20110114110342.4d95ad5b@nehalam>  <20110116223540.GA1861@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39230 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751903Ab1AQGzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 01:55:07 -0500
Received: by wwa36 with SMTP id 36so5094929wwa.1
        for <netdev@vger.kernel.org>; Sun, 16 Jan 2011 22:55:05 -0800 (PST)
In-Reply-To: <20110116223540.GA1861@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 16 janvier 2011 =C3=A0 23:35 +0100, Jarek Poplawski a =C3=A9=
crit :

> Why leave leaf classes with different stats?
>=20

I wanted to address this point in a followup patch, once general qdisc
stats changes are accepted.


