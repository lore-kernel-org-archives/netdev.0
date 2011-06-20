From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 5/5] ifb: convert to 64 bit stats (v3)
Date: Mon, 20 Jun 2011 23:44:38 +0200
Message-ID: <1308606278.2658.33.camel@edumazet-laptop>
References: <20110620203506.363818794@vyatta.com>
	 <20110620.135607.2158729745388010853.davem@davemloft.net>
	 <20110620141253.00249218@nehalam.ftrdhcpuser.net>
	 <1308604980.2658.23.camel@edumazet-laptop>
	 <1308605221.2658.25.camel@edumazet-laptop>
	 <20110620144230.29421b05@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45757 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752901Ab1FTVol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 17:44:41 -0400
Received: by wwe5 with SMTP id 5so2986644wwe.1
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 14:44:40 -0700 (PDT)
In-Reply-To: <20110620144230.29421b05@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 juin 2011 =C3=A0 14:42 -0700, Stephen Hemminger a =C3=A9cri=
t :
> Subject: ifb: convert to 64 bit stats
>=20
> Convert input functional block device to use 64 bit stats.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> ---
> v3 - split tx/rsync=20

Seems good :)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>



