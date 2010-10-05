From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: make __ipv6_isatap_ifid static
Date: Tue, 05 Oct 2010 08:25:00 +0200
Message-ID: <1286259900.2457.12.camel@edumazet-laptop>
References: <20101005151753.363121b8@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44782 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753967Ab0JEGZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 02:25:04 -0400
Received: by wwj40 with SMTP id 40so5187680wwj.1
        for <netdev@vger.kernel.org>; Mon, 04 Oct 2010 23:25:03 -0700 (PDT)
In-Reply-To: <20101005151753.363121b8@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 octobre 2010 =C3=A0 15:17 +0900, Stephen Hemminger a =C3=A9=
crit :
> Another exported symbol only used in one file
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


