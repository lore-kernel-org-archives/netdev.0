From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] Phonet: zero-copy GPRS TX
Date: Thu, 07 Jan 2010 00:25:15 -0800 (PST)
Message-ID: <20100107.002515.228784694.davem@davemloft.net>
References: <1262606569-3021-1-git-send-email-remi@remlab.net>
	<1262606569-3021-2-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, remi.denis-courmont@nokia.com
To: remi@remlab.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58198
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756141Ab0AGIZH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2010 03:25:07 -0500
In-Reply-To: <1262606569-3021-2-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi@remlab.net>
Date: Mon,  4 Jan 2010 14:02:48 +0200

> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> Send aligned pipe payload if requested to do so. Then, the socket buf=
fer
> needs not be fragmented anymore.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied to net-next-2.6
