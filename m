From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net: macb: allow deffered probe of the driver
Date: Mon, 26 Jan 2015 17:08:51 +0100
Message-ID: <54C66693.4080707@atmel.com>
References: <1421947441.717.4.camel@uti.ro> <54C6510C.8050002@atmel.com> <1422285264.2658.2.camel@uti.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"michal.simek@xilinx.com" <michal.simek@xilinx.com>
To: Nicolae Rosia <nicolae.rosia@certsign.ro>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:15084 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752553AbbAZQIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 11:08:55 -0500
In-Reply-To: <1422285264.2658.2.camel@uti.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/01/2015 16:21, Nicolae Rosia a =C3=A9crit :
> On Mon, 2015-01-26 at 15:37 +0100, Nicolas Ferre wrote:
>> Do you have a use case for this need?
> On my setup (Zynq Platform), the required clocks are
> provided by a module which is loaded after this driver,
> hence, the clock is not available at initialization time.

That's what I (actually Boris who I've consulted regarding this) felt.
Thanks for having confirmed this.

>> But anyway, it's not harmful:
>> Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> Thank you.
>=20
> Best regards,
> Nicolae Rosia
>=20

Bye,
--=20
Nicolas Ferre
