From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ks8842: Replace usage of dev_dbg with netdev_dbg
Date: Mon, 05 Jul 2010 19:08:08 -0700 (PDT)
Message-ID: <20100705.190808.68153438.davem@davemloft.net>
References: <1278285999.2594.4.camel@debian>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: richard.rojfors@pelagicore.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53013
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757522Ab0GFCHy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jul 2010 22:07:54 -0400
In-Reply-To: <1278285999.2594.4.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Richard R=F6jfors <richard.rojfors@pelagicore.com>
Date: Mon, 05 Jul 2010 01:26:39 +0200

> This patch replaces all usage of dev_dbg with netdev_dbg.
>=20
> A side effect is that the pointer to the platform device in the adapt=
er
> struct can be removed.
>=20
> Signed-off-by: Richard R=F6jfors <richard.rojfors@pelagicore.com>

Applied.
