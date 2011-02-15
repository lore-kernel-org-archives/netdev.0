From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/14] net/fec: release mem_region requested in probe
 in error path and remove
Date: Tue, 15 Feb 2011 10:31:59 -0800 (PST)
Message-ID: <20110215.103159.193730541.davem@davemloft.net>
References: <20110214082525.GD13279@pengutronix.de>
	<20110214.110549.193710827.davem@davemloft.net>
	<20110215085305.GL13279@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shawn.guo@freescale.com,
	kernel@pengutronix.de
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35797
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755768Ab1BOSbY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Feb 2011 13:31:24 -0500
In-Reply-To: <20110215085305.GL13279@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Tue, 15 Feb 2011 09:53:05 +0100

> On Mon, Feb 14, 2011 at 11:05:49AM -0800, David Miller wrote:
>> These merge commits look ugly and Linus wants them minimized.
> Hmm, right, I don't get why this looks uglier for Linus than a merge =
of
> a tree that bases on something you already have.  I guess you're too
> annoyed by now to explain why you think it does.

What's so hard to understand about the fact that when I pull from
someone I do not want any commits unrelated to the work that person
is sending me?

>> Either you follow the rules and my expectations, which is that when =
you
>> give me a GIT tree to pull from it's based upon one of my trees, or
>> I don't pull from you.
> So I rebased my tree on something older.  It now starts at
>=20
> 	c69b909 (pch_can: fix module reload issue with MSI)
>=20
> which is already in net-next/master.

You need to send a new pull request so that it gets properly tracked
in patchwork.
