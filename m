From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: bluetooth-next-2.6 2010-05-10
Date: Mon, 10 May 2010 04:08:55 -0700 (PDT)
Message-ID: <20100510.040855.215562962.davem@davemloft.net>
References: <cover.1273484094.git.marcel@holtmann.org>
	<20100510.024750.45124664.davem@davemloft.net>
	<1273488069.375.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37280
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753119Ab0EJLIu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 May 2010 07:08:50 -0400
In-Reply-To: <1273488069.375.30.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Marcel Holtmann <marcel@holtmann.org>
Date: Mon, 10 May 2010 12:41:09 +0200

> normally we don't have any big changes in the Bluetooth kernel side.
> This is the first one that adds a big set of features. And it is limi=
ted
> to the L2CAP layer. I took it out of last kernel release since it was
> incomplete and would not have been useful. Right now it is in a stage
> where it becomes usable. Only new profiles like the Health Medical st=
uff
> is making use of these features for now. However in the future more a=
nd
> more profile will requires support for it.
>=20
> The number of patches are not getting smaller. Except I arbitrarily
> merge them together. I am not planning to do that since I think it is
> not a good idea at all. And the patches have been reviewed by Jo=E3o =
Paulo
> Rechi Vita who worked with Gustavo on these changes.

It is your problem if you don't think there is any value to people
reviewing the stuff you're asking me to merge into the tree.

> So do you want to postpone this for 2.6.35 merge window?

I'll pull this stuff into net-next-2.6 after I give it a glance over
but you can't operate like this in the future.

Once you have about 10 commits ready in your tree, just push it to
me, don't delay.
