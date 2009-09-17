From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V2 0/3] at91_can: add support for Atmel's CAN controller
 on AT91SAM9263
Date: Thu, 17 Sep 2009 13:33:19 +0200
Message-ID: <4AB21E7F.1010506@pengutronix.de>
References: <1253180254-11910-1-git-send-email-mkl@pengutronix.de>	<4AB20679.2040602@grandegger.com> <4AB209CB.10707@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	Andrew Victor <linux@maxim.org.za>,
	linux-arm-kernel@lists.infradead.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45553 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbZIQLdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 07:33:50 -0400
In-Reply-To: <4AB209CB.10707@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Marc Kleine-Budde wrote:
> Wolfgang Grandegger wrote:
> Sorry, missed that. I was in a hurry, because they wanted to reboot the
> server....
> 
>>> cheers, Marc
>>>
>>> Marc Kleine-Budde (3):
>>>       at91sam9263: add at91_can device to generic device definition
>>>       at91sam9263ek: activate at91 CAN controller
>>>       at91_can: add driver for Atmel's CAN controller on AT91SAM9263
>> I have just added my "signed-off-by" for the Socket-CAN patch #3. Don't
>> known who will take care of the other patches.

Can you give me an Acked-by, too?

Marc

- --
Pengutronix e.K.                         | Marc Kleine-Budde           |
Linux Solutions for Science and Industry | Phone: +49-231-2826-924     |
Vertretung West/Dortmund                 | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686         | http://www.pengutronix.de   |
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkqyHn4ACgkQjTAFq1RaXHMuhwCfSczfgtF1mCwZmznJptah6mxC
NmAAn2hTsjL/OhNX9AM3/WPO+cs9NpKn
=ZotH
-----END PGP SIGNATURE-----
