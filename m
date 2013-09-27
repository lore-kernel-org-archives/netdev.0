From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can-next 2013-09-21
Date: Fri, 27 Sep 2013 02:10:50 -0400 (EDT)
Message-ID: <20130927.021050.603129866969698558.davem@davemloft.net>
References: <523DA52E.2030701@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <523DA52E.2030701@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Sat, 21 Sep 2013 15:54:54 +0200

> this is a pull request for net-next. It consists of two patches by Uw=
e
> Kleine-K=F6nig, they add explicit copyrights to the uapi CAN headers
> (including Acked-bys of the header authors). And 12 cleanup patches b=
y
> Jingoo Han. Several drivers are converted to use dev_get_platdata()
> instead of open coding it, two unnecessary pci_set_drvdata() are
> removed from the CAN PCI drivers.

Pulled, th anks.
