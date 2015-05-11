From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: macb: Handle the RXUBR interrupt on all devices
Date: Mon, 11 May 2015 10:28:15 -0400 (EDT)
Message-ID: <20150511.102815.1978586728654404293.davem@davemloft.net>
References: <1430856025-1066-1-git-send-email-nathan.sullivan@ni.com>
	<20150509.160454.1045911244389894144.davem@davemloft.net>
	<5550802E.6040900@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nathan.sullivan@ni.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nicolas.ferre@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34346 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbbEKO2V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 10:28:21 -0400
In-Reply-To: <5550802E.6040900@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas Ferre <nicolas.ferre@atmel.com>
Date: Mon, 11 May 2015 12:10:54 +0200

> Le 09/05/2015 22:04, David Miller a =E9crit :
>> From: Nathan Sullivan <nathan.sullivan@ni.com>
>> Date: Tue, 5 May 2015 15:00:25 -0500
>>=20
>>> The same hardware issue the at91 must work around applies to at lea=
st the
>>> Zynq ethernet, and possibly more devices.  The driver also needs to=
 handle
>>> the RXUBR interrupt since it turns it on with MACB_RX_INT_FLAGS any=
way.
>>>
>>> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
>>=20
>> Applied, thank you.
>=20
> A v2 of this patch with more explanation in both the commit message a=
nd
> in code comments had been sent. Not a big deal (I suspect you can't u=
se
> the v2 one, now that it's applied in your tree, can you?).

Sorry, yes I see there was a v2.  If you want to send me a relative pat=
ch that
corrects things, I can apply that.

Thanks.
