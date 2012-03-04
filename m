From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next] mlx4_en: dont change mac_header on xmit
Date: Sun, 4 Mar 2012 22:02:59 +0200
Message-ID: <CAJZOPZJMbXci1Ky1FHhgyAp0WgwrKFLijuMtOgYHnAfiCAe4Qw@mail.gmail.com>
References: <1330167065.2462.53.camel@edumazet-laptop>
	<CAJZOPZKAwrx-u_onDQCCxipkLPdZkPE6cokRtZOa1uRZiZTYug@mail.gmail.com>
	<1330876610.2730.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:52503 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754809Ab2CDUDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 15:03:00 -0500
Received: by lahj13 with SMTP id j13so3845075lah.19
        for <netdev@vger.kernel.org>; Sun, 04 Mar 2012 12:02:59 -0800 (PST)
In-Reply-To: <1330876610.2730.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 4, 2012 at 5:56 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> By the way you have existing problems about ctrl_flags

Yep, we will submit patch to fix that tomorrow or so


> I have to run, will submit official patch at the end of the (sunny)day, if you dont beat me

thanks

Or.
