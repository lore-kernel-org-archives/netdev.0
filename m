From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] WAN: protect HDLC proto list while insmod/rmmod
Date: Mon, 19 May 2008 14:06:19 -0700 (PDT)
Message-ID: <20080519.140619.99364727.davem@davemloft.net>
References: <20080512.033244.153113922.davem@davemloft.net>
	<m3lk2djbq3.fsf@maximus.localdomain>
	<m3ve1agrek.fsf_-_@maximus.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeff@garzik.org, alan@lxorguk.ukuu.org.uk, paulkf@microgate.com,
	jchapman@katalix.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58024
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754143AbYESVGY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 17:06:24 -0400
In-Reply-To: <m3ve1agrek.fsf_-_@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Halasa <khc@pm.waw.pl>
Date: Mon, 19 May 2008 19:00:51 +0200

> WAN: protect protocol list in hdlc.c with RTNL.
>    =20
> Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>

Acked-by: David S. Miller <davem@davemloft.net>
