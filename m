From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/10] [TCP]: Convert highest_sack to sk_buff to allow
 direct access
Date: Thu, 15 Nov 2007 19:42:16 -0800 (PST)
Message-ID: <20071115.194216.121056251.davem@davemloft.net>
References: <11951338543953-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11951338542528-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11951338542967-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53502
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757040AbXKPDmQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 22:42:16 -0500
In-Reply-To: <11951338542967-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 15 Nov 2007 15:37:28 +0200

> It is going to replace the sack fastpath hint quite soon... :-)
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

I always liked this patch, how can I not apply it? :-)

Added to net-2.6.25, thanks Ilpo!
