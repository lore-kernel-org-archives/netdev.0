From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] myri10ge: 64bit slice stats
Date: Mon, 20 Jun 2011 20:52:12 +0200
Message-ID: <1308595932.2658.17.camel@edumazet-laptop>
References: <20110620184635.GA18577@myri.com>
	 <1308595758.2658.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrew Gallatin <gallatin@myri.com>
To: Jon Mason <jon.mason@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58538 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816Ab1FTSwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 14:52:19 -0400
Received: by wwe5 with SMTP id 5so2858461wwe.1
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 11:52:17 -0700 (PDT)
In-Reply-To: <1308595758.2658.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 juin 2011 =C3=A0 20:49 +0200, Eric Dumazet a =C3=A9crit :

> Hmm, no sorry, this wont work on 32bit arches :(
>=20
> Please take a look at various patches addressing this problem.
>=20
>=20

=46or example take a look at the once sent some hours ago :

http://patchwork.ozlabs.org/patch/101128/



