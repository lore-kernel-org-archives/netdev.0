From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 5/5] Phonet: USB CDC Phonet function for gadget
 framework
Date: Mon, 29 Dec 2008 16:44:08 +0100
Message-ID: <1230565448.15666.25.camel@californication>
References: <200812171607.14184.remi.denis-courmont@nokia.com>
	 <1229522874-20636-5-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:55297 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751417AbYL2PnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2008 10:43:03 -0500
In-Reply-To: <1229522874-20636-5-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Remi,

> This implements the Nokia vendor-specific communication device class
> function to exchange Phonet messages over USB. This function is alrea=
dy
> found in the "PC suite" USB profile of (non-Linux) Nokia handsets.
>=20
> Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.co=
m>
> ---
>  drivers/usb/gadget/f_phonet.c |  621 +++++++++++++++++++++++++++++++=
++++++++++
>  drivers/usb/gadget/u_phonet.h |   21 ++
>  2 files changed, 642 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/usb/gadget/f_phonet.c
>  create mode 100644 drivers/usb/gadget/u_phonet.h

any reason why you didn't add an option to Kconfig to actually select
this gadget?

Regards

Marcel


