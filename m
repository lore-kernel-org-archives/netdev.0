From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Wed, 16 Jan 2008 23:16:54 -0800 (PST)
Message-ID: <20080116.231654.74131878.davem@davemloft.net>
References: <E1JFHDM-00010A-00@gondolin.me.apana.org.au>
	<478EF542.1010702@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47538
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751022AbYAQHRA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 02:17:00 -0500
In-Reply-To: <478EF542.1010702@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo_Ter=E4s <timo.teras@iki.fi>
Date: Thu, 17 Jan 2008 08:27:14 +0200

> I don't know about netlink. But pfkey works in *BSD too and it is RFC=
'd.
> So I'd say pfkey might be a bit more portable. Though netlink is defi=
nitely
> more robust and extensive.

The RFCs say absolutely nothing about policy interfaces for AF_KEY,
everybody rolls their own in slightly incompatible ways.

It is therefore anything but standardized.
