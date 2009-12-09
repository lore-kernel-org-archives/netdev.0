From: David Miller <davem@davemloft.net>
Subject: Re: scp stalls mysteriously
Date: Tue, 08 Dec 2009 20:54:32 -0800 (PST)
Message-ID: <20091208.205432.144399522.davem@davemloft.net>
References: <20091203202328.62d7551a@houba>
	<4B1ADF79.6000101@tvk.rwth-aachen.de>
	<alpine.DEB.2.00.0912071532080.7024@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: damian@tvk.rwth-aachen.de, fredo@starox.org,
	netdev@vger.kernel.org, eric.dumazet@gmail.com,
	herbert@gondor.apana.org.au, gregkh@suse.de
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44194
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756878AbZLIEyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 23:54:25 -0500
In-Reply-To: <alpine.DEB.2.00.0912071532080.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 7 Dec 2009 16:01:53 +0200 (EET)

> [PATCH] tcp: fix retrans_stamp advancing in error cases

Applied to net-2.6

Not queued to -stable, let me know if that becomes necessary.

Thanks!
