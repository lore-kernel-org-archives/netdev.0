From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] netlink: netlink_recvmsg() fix
Date: Mon, 16 Aug 2010 08:10:02 +0200
Message-ID: <1281939002.2942.70.camel@edumazet-laptop>
References: <1281710115.3760.27.camel@jlt3.sipsolutions.net>
	 <1281710887.4470.78.camel@edumazet-laptop>
	 <1281712433.2116.15.camel@jlt3.sipsolutions.net>
	 <20100814.223722.116371746.davem@davemloft.net>
	 <1281936351.3683.1.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:54055 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752502Ab0HPGKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 02:10:08 -0400
Received: by wwf26 with SMTP id 26so3872344wwf.1
        for <netdev@vger.kernel.org>; Sun, 15 Aug 2010 23:10:07 -0700 (PDT)
In-Reply-To: <1281936351.3683.1.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 16 ao=C3=BBt 2010 =C3=A0 07:25 +0200, Johannes Berg a =C3=A9cr=
it :

> I haven't gotten around to it, but Kalle had been running into the sa=
me
> issue and said reverting it fixed it:
>=20
> http://article.gmane.org/gmane.linux.kernel.wireless.general/54492
>=20

Thanks Johannes

Please David revert 1235f504.

We'll find another way to address the problem.



