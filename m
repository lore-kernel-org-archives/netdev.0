From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH net-next] fq_codel: add batch ability to fq_codel_drop()
Date: Mon, 2 May 2016 18:07:54 -0700
Message-ID: <CAA93jw4AnPdNCZPbkCTLAm3jpDDO3OBx480o8MSKjPGRSEDEvw@mail.gmail.com>
References: <1462146446.5535.236.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160502094954.24cc9549@redhat.com>
	<1462199668.5535.239.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160502180036.25bebdfe@redhat.com>
	<1462205571.5535.253.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160502191543.170fc046@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jonathan Morton <chromatix99@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:34354 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932284AbcECBHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 21:07:55 -0400
Received: by mail-oi0-f54.google.com with SMTP id k142so6986246oib.1
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 18:07:55 -0700 (PDT)
In-Reply-To: <20160502191543.170fc046@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have duplicated the issue on my own hardware. I would like to
explore also upping the codel count in this scenario at some point,
but:

Acked-by: Dave Taht
