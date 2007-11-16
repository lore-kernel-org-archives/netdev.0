From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/10] [TCP]: Move !in_sack test earlier in sacktag &
 reorganize if()s
Date: Thu, 15 Nov 2007 19:33:56 -0800 (PST)
Message-ID: <20071115.193356.113032639.davem@davemloft.net>
References: <11951338542267-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1195133854795-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52090
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765521AbXKPDd4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 22:33:56 -0500
In-Reply-To: <1195133854795-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 15 Nov 2007 15:37:25 +0200

> All intermediate conditions include it already, make them
> simpler as well.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied to net-2.6.25
