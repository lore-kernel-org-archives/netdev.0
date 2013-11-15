From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: phy: use phy_init_hw instead of
 open-coding it
Date: Fri, 15 Nov 2013 02:30:48 -0500 (EST)
Message-ID: <20131115.023048.1035405828290283938.davem@davemloft.net>
References: <1384495793-22534-1-git-send-email-f.fainelli@gmail.com>
	<2068298.FXgGSfs2Vb@lenovo>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55319 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042Ab3KOHaw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 02:30:52 -0500
In-Reply-To: <2068298.FXgGSfs2Vb@lenovo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 15 Nov 2013 07:03:04 +0000

> Le vendredi 15 novembre 2013, 06:09:53 Florian Fainelli a =E9crit :
>> We already have a helper function which verifies a PHY device driver
>> implements a config_init callback, then calls phy_scan_fixups() and
>> ultimately calls the config_init callback. Use that instead of open
>> coding it.
>=20
> I did not realize we were in the middle of the merge window, I will r=
e-submit=20
> once net-next is open again since this is not a fix.

Thank you.
