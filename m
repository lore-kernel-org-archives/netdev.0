From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] cdc-ether: clean packet filter upon probe
Date: Mon, 25 Aug 2014 10:07:43 +0200
Message-ID: <1408954063.10300.1.camel@linux-fkkt.site>
References: <1406537796-20156-1-git-send-email-oneukum@suse.de>
	 <87a977z5pn.fsf@nemi.mork.no> <1408083121.17565.4.camel@linux-fkkt.site>
	 <87d2c2xm2k.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35726 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753053AbaHYIHq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2014 04:07:46 -0400
In-Reply-To: <87d2c2xm2k.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-08-15 at 09:13 +0200, Bj=C3=B8rn Mork wrote:
> Oliver Neukum <oneukum@suse.de> writes:
>=20
> > On Thu, 2014-08-14 at 13:11 +0200, Bj=C3=B8rn Mork wrote:

> > Support for this request is mandatory.
>=20
> Yes, there is no problem for standard conforming ECM devices.  I full=
y
> agree there.=20
>=20
> But standard conformance is unfortunately not something we can expect=
=2E
> My question was regarding the non-conforming devices, like the ones
> supported by th zaurus and rndis_host drivers.  These drivers are mad=
e

You have a point. Yet another flag? Do you see an alternative?

	Regards
		Oliver
