From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] WAN: protect Cisco HDLC state changes with a spinlock.
Date: Mon, 19 May 2008 14:07:07 -0700 (PDT)
Message-ID: <20080519.140707.262584018.davem@davemloft.net>
References: <m3od72gqxf.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeff@garzik.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58030
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755902AbYESVHM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 17:07:12 -0400
In-Reply-To: <m3od72gqxf.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Halasa <khc@pm.waw.pl>
Date: Mon, 19 May 2008 19:11:08 +0200

> WAN: protect Cisco HDLC state changes with a spinlock.
>    =20
> Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>

Acked-by: David S. Miller <davem@davemloft.net>
