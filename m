From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Tue, 29 Nov 2011 15:29:46 +0100
Message-ID: <1322576986.2465.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <alpine.DEB.2.00.1111281825200.25622@pokey.mtv.corp.google.com>
	 <CAA93jw7P=7YMOS_sMQWBJx0UJ6e+xw4e_hw8szNiVTOjGNwukw@mail.gmail.com>
	 <1322550138.2970.70.camel@edumazet-laptop>
	 <1322576645.7454.48.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Taht <dave.taht@gmail.com>, Tom Herbert <therbert@google.com>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:60748 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755685Ab1K2O3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 09:29:51 -0500
Received: by qyk4 with SMTP id 4so1607282qyk.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 06:29:50 -0800 (PST)
In-Reply-To: <1322576645.7454.48.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 29 novembre 2011 =C3=A0 14:24 +0000, Ben Hutchings a =C3=A9cri=
t :

> Not if you separate hardware queues by priority (and your high priori=
ty
> packets are non-TCP or PuSHed).

I mostly have tg3 , bnx2 cards, mono queues...

I presume Dave, working on small Wifi/ADSL routers have same kind of
hardware.
