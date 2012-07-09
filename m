From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r6040: use module_pci_driver macro
Date: Mon, 09 Jul 2012 14:43:00 -0700 (PDT)
Message-ID: <20120709.144300.1458973428286984287.davem@davemloft.net>
References: <1341763077-938-1-git-send-email-devendra.aaru@gmail.com>
	<201207082339.17996.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: devendra.aaru@gmail.com, netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59498 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754347Ab2GIVnA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 17:43:00 -0400
In-Reply-To: <201207082339.17996.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Fainelli <florian@openwrt.org>
Date: Sun, 8 Jul 2012 23:39:17 +0200

> Le dimanche 08 juillet 2012 17:57:57, Devendra Naga a =E9crit :
>> as the manual of module_pci_driver says that
>> it can be used when the init and exit functions of
>> the module does nothing but the pci_register_driver
>> and pci_unregister_driver.
>>=20
>> use it for rdc's r6040 driver, as the init and exit
>> paths does as above, and also this reduces a little
>> amount of code.
>>=20
>> Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>
>=20
> Acked-by: Florian Fainelli <florian@openwrt.org>

Applied.
