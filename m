From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Phonet: fix oops in phonet_address_del() on
 non-Phonet device
Date: Wed, 26 Nov 2008 15:27:05 -0800 (PST)
Message-ID: <20081126.152705.141246718.davem@davemloft.net>
References: <1227703319-26719-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55611
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750996AbYKZX1F convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2008 18:27:05 -0500
In-Reply-To: <1227703319-26719-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Wed, 26 Nov 2008 14:41:59 +0200

> A NULL dereference would occur when trying to delete an addres from a
> network device that does not have any Phonet address.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied, thanks.
