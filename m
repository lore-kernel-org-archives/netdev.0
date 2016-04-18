From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: bcmgenet: device stats are unsigned long
Date: Sun, 17 Apr 2016 17:49:45 -0700
Message-ID: <57142F29.6080502@gmail.com>
References: <1460742472.10638.78.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:34460 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189AbcDRAtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2016 20:49:49 -0400
Received: by mail-oi0-f53.google.com with SMTP id k142so17432521oib.1
        for <netdev@vger.kernel.org>; Sun, 17 Apr 2016 17:49:49 -0700 (PDT)
In-Reply-To: <1460742472.10638.78.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/04/2016 10:47, Eric Dumazet a =C3=A9crit :
> From: Eric Dumazet <edumazet@google.com>
>=20
> On 64bit kernels, device stats are 64bit wide, not 32bit.
>=20
> Fixes: 1c1008c793fa4 ("net: bcmgenet: add main driver file")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Florian Fainelli <f.fainelli@gmail.com>

Late, but:

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks Eric!
--=20
=46lorian
