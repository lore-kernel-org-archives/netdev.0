From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: allow TSO being set on bonding master
Date: Wed, 15 May 2013 16:18:20 -0700
Message-ID: <1368659900.4519.57.camel@edumazet-glaptop>
References: <1368654065.4519.53.camel@edumazet-glaptop>
	 <CAHXqBF+r3wnWY+hveYjVBNwbVYdiDF4mOj1UmbKeH3OYo6kz6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:51408 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753315Ab3EOXSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 19:18:22 -0400
Received: by mail-da0-f46.google.com with SMTP id e20so1261654dak.5
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 16:18:22 -0700 (PDT)
In-Reply-To: <CAHXqBF+r3wnWY+hveYjVBNwbVYdiDF4mOj1UmbKeH3OYo6kz6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-16 at 00:55 +0200, Micha=C5=82 Miros=C5=82aw wrote:

> Have you tried adding it to NETIF_F_ONE_FOR_ALL set? 'Team' and bridg=
e
> could then also use it.

Good point, I am testing this, thanks !
