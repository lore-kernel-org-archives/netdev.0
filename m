From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] [TCP]: Must count fack_count also when skipping
Date: Tue, 25 Mar 2008 20:05:01 -0700 (PDT)
Message-ID: <20080325.200501.203623674.davem@davemloft.net>
References: <pan.2008.03.24.20.36.07@telenet.be>
	<20080324.144107.235200795.davem@davemloft.net>
	<Pine.LNX.4.64.0803250942450.14461@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fhimpe@telenet.be, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59523
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751808AbYCZDFG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 23:05:06 -0400
In-Reply-To: <Pine.LNX.4.64.0803250942450.14461@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 25 Mar 2008 23:24:55 +0200 (EET)

> Please don't, it's not the right fix, it fixed a bug that was
> introduced post 2.6.24 by this commit:

Ok.

> Btw, it would have been polite to cc me as well (I suppose you just d=
idn't=20
> notice that somebody dropped me in between :-)), not a big prob thoug=
h as=20
> I found it out early anyway because I'm trying to catch up what has b=
een=20
> reported against TCP during my week away.

Sorry, my bad.
