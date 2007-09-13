From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Fix a lock problem in generic phy code
Date: Thu, 13 Sep 2007 00:12:52 -0400
Message-ID: <46E8B8C4.5010203@garzik.org>
References: <200708311430.09590.hjk@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	afleming@freescale.com
To: =?ISO-8859-1?Q?Hans-J=FCrgen_Koch?= <hjk@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46649 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751411AbXIMEM4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 00:12:56 -0400
In-Reply-To: <200708311430.09590.hjk@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hans-J=FCrgen Koch wrote:
> Lock debugging finds a problem in phy.c and phy_device.c,
> this patch fixes it. Tested on an AT91SAM9263-EK board,=20
> kernel 2.6.23-rc4.
>=20
> Signed-off-by: Hans J. Koch <hjk@linutronix.de>

applied


