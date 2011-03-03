From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] udp: udp_sendmsg() fix
Date: Thu, 03 Mar 2011 20:02:04 +0100
Message-ID: <1299178924.2547.0.camel@edumazet-laptop>
References: <1299169686.2983.129.camel@edumazet-laptop>
	 <1299172043.2983.142.camel@edumazet-laptop>
	 <20110303.104226.71110201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:52371 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758207Ab1CCTCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 14:02:09 -0500
Received: by bwz15 with SMTP id 15so1442619bwz.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 11:02:08 -0800 (PST)
In-Reply-To: <20110303.104226.71110201.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 mars 2011 =C3=A0 10:42 -0800, David Miller a =C3=A9crit :

> My version NULL's out rt, so that if we had any changes in code paths
> here it would be unlikely we'd reintroduce this bug.
>=20
> I'm fine either way, although my version is in net-next-2.6 at the
> moment :-)

No problem, your version pleases me as well ;)



