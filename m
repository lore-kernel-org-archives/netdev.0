From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2]: softirq: Add support for triggering softirq work
 on softirqs.
Date: Thu, 18 Sep 2008 02:36:14 -0700 (PDT)
Message-ID: <20080918.023614.193687634.davem@davemloft.net>
References: <20080918043542.GJ20055@kernel.dk>
	<20080917.215053.116422969.davem@davemloft.net>
	<Pine.LNX.4.64.0809181033250.1034@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jens.axboe@oracle.com, netdev@vger.kernel.org,
	nickpiggin@yahoo.com.au
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51672
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753837AbYIRJg0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2008 05:36:26 -0400
In-Reply-To: <Pine.LNX.4.64.0809181033250.1034@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 18 Sep 2008 10:40:06 +0300 (EEST)

> I suppose you could add lkml too as Andrew might not be happy if this=
=20
> kind of thing gets done behind his back on netdev/net-next only=20
> (considering some past experience)? :-)

Yep, good idea, I'll do that when I next report this stuff.
