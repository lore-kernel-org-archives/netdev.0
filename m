From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH V2 0/3] at91_can: add support for Atmel's CAN
	controller on AT91SAM9263
Date: Mon, 21 Sep 2009 22:40:31 +0100
Message-ID: <20090921214031.GI30821@n2100.arm.linux.org.uk>
References: <1253180254-11910-1-git-send-email-mkl@pengutronix.de> <4AB20679.2040602@grandegger.com> <4AB209CB.10707@pengutronix.de> <cd73a99e0909211431k37429a70o4efaac7104f7d526@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	Andrew Victor <linux@maxim.org.za>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-arm-kernel@lists.infradead.org
To: Andrew Victor <avictor.za@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:37945 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697AbZIUVkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2009 17:40:55 -0400
Content-Disposition: inline
In-Reply-To: <cd73a99e0909211431k37429a70o4efaac7104f7d526@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 21, 2009 at 11:31:19PM +0200, Andrew Victor wrote:
> hi Marc,
>=20
> >>> Marc Kleine-Budde (3):
> >>> =A0 =A0 =A0 at91sam9263: add at91_can device to generic device de=
finition
> >>> =A0 =A0 =A0 at91sam9263ek: activate at91 CAN controller
> >>> =A0 =A0 =A0 at91_can: add driver for Atmel's CAN controller on AT=
91SAM9263
> >>
> >> I have just added my "signed-off-by" for the Socket-CAN patch #3. =
Don't
> >> known who will take care of the other patches.
> >
> > Thanks Wolfgang.
> >
> > Andrew, are the first two going throught the arm tree?
>=20
> That would be best.
> Please submit them to Russell King's patch system.

While we're at at91 stuff, please can someone see about fixing the
AC97 breakage with at91cap9adk_defconfig please, or confirming that
patches I already have fix this?
