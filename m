From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH] net: fec: fix initial runtime PM refcount
Date: Tue, 4 Aug 2015 11:59:36 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1508041159100.1577-100000@iolanthe.rowland.org>
References: <20150804143555.GQ9999@pengutronix.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lucas Stach <l.stach@pengutronix.de>, Andrew Lunn <andrew@lunn.ch>,
	Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>,
	<netdev@vger.kernel.org>, <linux-pm@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	<patchwork-lst@pengutronix.de>, <kernel@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20150804143555.GQ9999@pengutronix.de>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 4 Aug 2015, Uwe [iso-8859-1] Kleine-K=F6nig wrote:

> Hello,
>=20
> On Tue, Aug 04, 2015 at 10:20:55AM -0400, Alan Stern wrote:
> > In that case, adding a call pm_runtime_get_noresume() is the right=20
> > thing to do.
> Is this an ack for Lucas' patch?

Yes:

Acked-by: Alan Stern <stern@rowland.harvard.edu>

Alan Stern

