From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ifb: add performance flags to
 dev->features
Date: Tue, 28 Dec 2010 23:36:21 +0100
Message-ID: <1293575781.20573.391.camel@edumazet-laptop>
References: <20101220130247.GB9325@ff.dom.local>
	 <AANLkTi=eqCWpFpHQ86_yO544p5G6J6P2os7rCR9FBtUd@mail.gmail.com>
	 <1292855120.2800.45.camel@edumazet-laptop>
	 <20101228.135013.39173075.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, jarkao2@gmail.com, pstaszewski@itcare.pl,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44448 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788Ab0L1Wgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Dec 2010 17:36:32 -0500
Received: by wwa36 with SMTP id 36so10219070wwa.1
        for <netdev@vger.kernel.org>; Tue, 28 Dec 2010 14:36:30 -0800 (PST)
In-Reply-To: <20101228.135013.39173075.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 28 d=C3=A9cembre 2010 =C3=A0 13:50 -0800, David Miller a =C3=A9=
crit :

> Changli has suggested that these flags can also be set in
> ->vlan_features, please address that if you expect me to
> apply the change.

Hmm, I am just scratching my head to actually setup vlans on top of ifb=
,
to test such a change ?





