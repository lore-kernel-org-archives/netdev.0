From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bridge: reset IPCB in br_parse_ip_options
Date: Wed, 13 Apr 2011 17:28:07 +0200
Message-ID: <1302708487.3725.0.camel@edumazet-laptop>
References: <4DA3F909.5020609@scotdoyle.com>
	 <1302608951.3233.33.camel@edumazet-laptop>
	 <1302613353.30934.22.camel@polaris.local>
	 <1302614145.3233.47.camel@edumazet-laptop>
	 <1302617968.30934.34.camel@polaris.local>
	 <1302619749.3233.56.camel@edumazet-laptop>
	 <1302621233.30934.44.camel@polaris.local>
	 <1302624851.3233.63.camel@edumazet-laptop>
	 <20110412092039.69f420f6@nehalam>
	 <1302626152.3233.66.camel@edumazet-laptop>
	 <20110412164557.GF2047@stratus.com>
	 <1302627281.3233.70.camel@edumazet-laptop>
	 <1302628720.3233.84.camel@edumazet-laptop> <4DA4E68B.9010401@scotdoyle.com>
	 <4DA522B2.90200@scotdoyle.com>  <4DA5BCF7.9020606@scotdoyle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	netdev@vger.kernel.org
To: Scot Doyle <lkml@scotdoyle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64433 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757251Ab1DMP2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 11:28:12 -0400
Received: by wwa36 with SMTP id 36so870782wwa.1
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2011 08:28:11 -0700 (PDT)
In-Reply-To: <4DA5BCF7.9020606@scotdoyle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 13 avril 2011 =C3=A0 10:10 -0500, Scot Doyle a =C3=A9crit :

> The net effect is that three patches are required to eliminate the pa=
nics.
>=20
> These two patches have been accepted by David:
> http://article.gmane.org/gmane.linux.network/192015
> http://article.gmane.org/gmane.linux.network/192055
>=20
> This patch, incrementally authored by Stephen and Eric and compiled b=
y=20
> me, is also required:
> http://article.gmane.org/gmane.linux.network/192007
>=20
> What should happen for this third patch to be included upstream?

Dont worry, Stephen or me will send it asap.

Thanks


