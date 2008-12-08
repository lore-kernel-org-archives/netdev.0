From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Phonet: hold GPRS device while cleaning up
Date: Mon, 08 Dec 2008 03:45:33 -0800 (PST)
Message-ID: <20081208.034533.97506116.davem@davemloft.net>
References: <1228730965-19087-1-git-send-email-remi.denis-courmont@nokia.com>
	<20081208.022153.93642210.davem@davemloft.net>
	<200812081303.55322.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38421
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756327AbYLHLpc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2008 06:45:32 -0500
In-Reply-To: <200812081303.55322.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "R=E9mi Denis-Courmont" <remi.denis-courmont@nokia.com>
Date: Mon, 8 Dec 2008 13:03:55 +0200

> On Monday 08 December 2008 12:21:53 ext David Miller, you wrote:
> > Can we get the phonet stack using more sensible local
> > variable names for netdev pointers?
>=20
> Sure. Should I send a large cosmetic s/net/dev/ et al patch against n=
et-next?

That would work just fine, thanks.
