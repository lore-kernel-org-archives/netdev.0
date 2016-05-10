From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can-next 2016-05-09,pull-request: can-next
 2016-05-09
Date: Tue, 10 May 2016 14:19:33 -0400 (EDT)
Message-ID: <20160510.141933.860450741621345452.davem@davemloft.net>
References: <5730639F.2030104@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
	linux-can@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41988 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162AbcEJSTf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 14:19:35 -0400
In-Reply-To: <5730639F.2030104@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Mon, 9 May 2016 12:17:03 +0200

> this is a pull request of 12 patches for net-next/master.
>=20
> Alexander Gerasiov and Nikita Edward Baruzdin each contribute a patch
> improving the sja1000 driver. Amitoj Kaur Chawla's patch converts the
> mcp251x driver to alloc_workqueue(). A patch by Oliver Hartkopp fixes
> the handling of CAN config options. Andreas Gr=F6ger improves the err=
or
> handling in the janz-ican3 driver. The patch by Maximilian Schneider
> for the gs_usb improves probing of the USB driver. Finally there are =
6
> improvement patches by Marek Vasut for the ifi CAN driver.

Pulled, thanks Marc.
