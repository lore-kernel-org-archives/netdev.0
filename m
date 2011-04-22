From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] net: fix hw_features ethtool_ops->set_flags
 compatibility
Date: Fri, 22 Apr 2011 07:27:10 +0200
Message-ID: <1303450030.13893.7.camel@edumazet-laptop>
References: <20110421231232.BF22613909@rere.qmqm.pl>
	 <1303426342.3464.184.camel@localhost> <20110421221548.GA7888@rere.qmqm.pl>
	 <20110412144940.GA26043@rere.qmqm.pl>
	 <20110411202630.C079D13909@rere.qmqm.pl>
	 <1302610228.32697.298.camel@lb-tlvb-vladz>
	 <20110412140708.GA21835@rere.qmqm.pl>
	 <1302619012.6750.8.camel@lb-tlvb-vladz>
	 <20110412193823.0823213A65@rere.qmqm.pl>
	 <1303397531.3685.16.camel@edumazet-laptop>
	 <1303411750.19212.123.camel@lb-tlvb-vladz>
	 <1303413559.3165.55.camel@bwh-desktop> <20110421221548.GA7888@rere.qmqm.pl>
	 <20110421235921.89D1D13909@rere.qmqm.pl>
	 <1303449402.13893.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	Vladislav Zolotarov <vladz@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53916 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943Ab1DVF1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 01:27:15 -0400
Received: by wwa36 with SMTP id 36so387948wwa.1
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 22:27:14 -0700 (PDT)
In-Reply-To: <1303449402.13893.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 22 avril 2011 =C3=A0 07:16 +0200, Eric Dumazet a =C3=A9crit=
 :

> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Tested-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Thanks, this solves the bnx2x problem !
>=20

And already in net-next-2.6 ;)



