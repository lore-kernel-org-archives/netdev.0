From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/10]: tcp & more tcp
Date: Fri, 05 Dec 2008 22:49:58 -0800 (PST)
Message-ID: <20081205.224958.07873372.davem@davemloft.net>
References: <1228510736-3655-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41092
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751710AbYLFGt6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Dec 2008 01:49:58 -0500
In-Reply-To: <1228510736-3655-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri,  5 Dec 2008 22:58:46 +0200

> 1) Some fixes to recent work, and some to pre-historic things.
>=20
> 2) sacktag state struct to avoid ..., *ptr, *ptr2, *ptr3 crazyness
>=20
> 3) Besides that combine some code here and there.

All applied, but I had to pull in net-2.6 into net-next-2.6
along the way or else patch 9 wouldn't apply.

Thanks.
