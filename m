From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] Phonet: use atomic for packet TX window
Date: Wed, 17 Dec 2008 15:53:01 -0800 (PST)
Message-ID: <20081217.155301.167056384.davem@davemloft.net>
References: <200812171607.14184.remi.denis-courmont@nokia.com>
	<1229522874-20636-3-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48464
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752551AbYLQXw7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 18:52:59 -0500
In-Reply-To: <1229522874-20636-3-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Wed, 17 Dec 2008 16:07:52 +0200

> GPRS TX flow control won't need to lock the underlying socket anymore=
=2E
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied.
