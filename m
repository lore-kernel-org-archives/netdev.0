From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 1/2] tcp: Stalling connections: Fix timeout
 calculation routine
Date: Tue, 08 Dec 2009 20:53:13 -0800 (PST)
Message-ID: <20091208.205313.141219308.davem@davemloft.net>
References: <4B1CE45A.9010908@tvk.rwth-aachen.de>
	<4B1D27F7.9000502@tvk.rwth-aachen.de>
	<alpine.DEB.2.00.0912072046500.27565@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: damian@tvk.rwth-aachen.de, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, fredo@starox.org,
	herbert@gondor.apana.org.au, gregkh@suse.de
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44184
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755803AbZLIExH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 23:53:07 -0500
In-Reply-To: <alpine.DEB.2.00.0912072046500.27565@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 7 Dec 2009 20:50:11 +0200 (EET)

> Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> 
> Also, this should be added:
> 
> Reported-by: Frederic Leroy <fredo@starox.org>
> 
> ...and I think he has already tested this fix a number of times in 
> different forms, so I'd already include his Tested-by: too.

Done, applied, and I'll get this to -stable as quickly as I can.

Thanks everyone for all of your hard work!
