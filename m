From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] Minor code cleanup in drivers/net/r6040.c
Date: Sun, 05 Jul 2009 19:48:16 -0700 (PDT)
Message-ID: <20090705.194816.40719812.davem@davemloft.net>
References: <1245913509-23245-1-git-send-email-michael@free-electrons.com>
	<200906251018.40995.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: michael@free-electrons.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36973
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753351AbZGFCsJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jul 2009 22:48:09 -0400
In-Reply-To: <200906251018.40995.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Fainelli <florian@openwrt.org>
Date: Thu, 25 Jun 2009 10:18:40 +0200

> Le Thursday 25 June 2009 09:05:09 Michael Opdenacker, vous avez =E9cr=
it=A0:
>>  Replaced '0' by 'bar' in the probe function.
>>  The 'bar' variable was already set to '0' and is already
>>  used in pci_iomap(). This is cleaner and improves code
>>  consistency.
>>
>> Signed-off-by: Michael Opdenacker <michael@free-electrons.com>
>=20
> Acked-by: Florian Fainelli <florian@openwrt.org>

Applied to net-next-2.6
