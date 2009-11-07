From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Phonet: use rwlock for sockets list
Date: Fri, 06 Nov 2009 18:03:56 -0800 (PST)
Message-ID: <20091106.180356.132016300.davem@davemloft.net>
References: <65081524fbfeb975c842ebc79a8fb038@chewa.net>
	<4AF42C07.4050008@gmail.com>
	<200911061629.42911.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35322
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754280AbZKGCDa convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Nov 2009 21:03:30 -0500
In-Reply-To: <200911061629.42911.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "R=E9mi Denis-Courmont" <remi.denis-courmont@nokia.com>
Date: Fri, 6 Nov 2009 16:29:42 +0200

> So if you say R/W locks suck, screw this patch.

They do, so I'm tossing it :-)
