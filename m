From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: frto should not set snd_cwnd to 0
Date: Tue, 05 Feb 2013 11:44:40 -0800
Message-ID: <1360093480.28557.8.camel@edumazet-glaptop>
References: <20130123161238.GE8912@reaktio.net>
	 <20130123214445.GA16641@order.stressinduktion.org>
	 <20130123215151.GF8912@reaktio.net>
	 <20130123152642.4a8389ba@nehalam.linuxnetplumber.net>
	 <20130123234116.GC16641@order.stressinduktion.org>
	 <1358984831.12374.1227.camel@edumazet-glaptop>
	 <20130124135120.GD16641@order.stressinduktion.org>
	 <1359777110.30177.58.camel@edumazet-glaptop>
	 <20130202142832.GP8912@reaktio.net>
	 <1359818075.30177.78.camel@edumazet-glaptop>
	 <CADVnQykbufy-kQrEnJm0bbt=n7C8OfE1=Kr-2KfP7Mbu5Eq58w@mail.gmail.com>
	 <1359826377.30177.86.camel@edumazet-glaptop>
	 <1359918785.30177.111.camel@edumazet-glaptop>
	 <alpine.DEB.2.00.1302041327210.4561@wel-95.cs.helsinki.fi>
	 <1359990461.30177.142.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	Pasi =?ISO-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f43.google.com ([209.85.210.43]:41451 "EHLO
	mail-da0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755421Ab3BETon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 14:44:43 -0500
Received: by mail-da0-f43.google.com with SMTP id u36so212169dak.30
        for <netdev@vger.kernel.org>; Tue, 05 Feb 2013 11:44:43 -0800 (PST)
In-Reply-To: <1359990461.30177.142.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-02-04 at 07:07 -0800, Eric Dumazet wrote:

> Thanks Ilpo.
> 
> I'll be able to test your patch under load only in ~8 hours.

Sorry for the delay.

The patch survived my tests ;)

Tested-by: Eric Dumazet <edumazet@google.com>
