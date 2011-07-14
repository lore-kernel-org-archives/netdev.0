From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 09/10] net: remove /sys/class/net/*/features
Date: Thu, 14 Jul 2011 02:03:59 +0100
Message-ID: <1310605439.2756.17.camel@bwh-desktop>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
	 <ce3c2d463fa75fe00052658cf29e73375f965ab7.1310601401.git.mirq-linux@rere.qmqm.pl>
	 <20110713175037.7cbf772a@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:10191 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204Ab1GNBEC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 21:04:02 -0400
In-Reply-To: <20110713175037.7cbf772a@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-07-13 at 17:50 -0700, Stephen Hemminger wrote:
> On Thu, 14 Jul 2011 02:10:30 +0200 (CEST)
> Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> wrote:
>=20
> > The same information and more can be obtained by using ethtool
> > with ETHTOOL_GFEATURES.
> >=20
> > Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
>=20
> Changing user visible API has to go through a longer process
> such as putting it in feature-removal-schedule.txt for a while
> (at couple of releases) before removing.

We already established that this ABI has been changed repeatedly by
renumbering of features.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

