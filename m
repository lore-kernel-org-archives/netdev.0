From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] dont create cached routes from ARP requests
Date: Fri, 24 Sep 2010 17:34:57 +0200
Message-ID: <1285342497.2503.260.camel@edumazet-laptop>
References: <20100922162209.GA10281@babylon>
	 <20100922.203442.233700254.davem@davemloft.net>
	 <20100923144708.GA8037@babylon> <1285254302.2509.47.camel@edumazet-laptop>
	 <4C9CBCFC.6080300@gmail.com>  <1285342083.2503.252.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ulrich Weber <uweber@astaro.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ulrich Weber <ulrich.weber@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52936 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753298Ab0IXPfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 11:35:02 -0400
Received: by fxm3 with SMTP id 3so785076fxm.19
        for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 08:35:01 -0700 (PDT)
In-Reply-To: <1285342083.2503.252.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 24 septembre 2010 =C3=A0 17:28 +0200, Eric Dumazet a =C3=A9=
crit :

> What are the packets you receive ? A flood of ARP answers ?
>=20
> a "tcpdump -X" of a few packets would help to understand.
>=20
>=20


Also please report=20

grep . `find /proc/sys -name arp_accept`



