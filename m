From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: Re: [PATCH] Add support the Korina (IDT RC32434) Ethernet MAC
Date: Mon, 10 Mar 2008 21:55:37 +0100
Message-ID: <200803102155.38671.florian.fainelli@telecomint.eu>
References: <200803052345.06610.florian.fainelli@telecomint.eu> <1204886746.6387.17.camel@johannes.berg> <200803081905.46020.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, Felix Fietkau <nbd@openwrt.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:35856 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbYCJUzo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2008 16:55:44 -0400
In-Reply-To: <200803081905.46020.florian.fainelli@telecomint.eu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, Jeff,

Any comments on this driver ?

Thank you.

Le samedi 8 mars 2008, Florian Fainelli a =E9crit=A0:
> Hi Johannes,
>
> Thanks for your comments, here is the second try.
> ---
> From: Florian Fainelli <florian.fainelli@telecomint.eu>
> Subject: [PATCH] Add support the Korina (IDT RC32434) Ethernet MAC
>
> This patch adds support for the IDT rc32434 Ethernet MAC
> we can find in the IDT boards and the Mikrotik RB500.
> Driver references some code from the linux-mips RB500
> support.
>
> Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
> Signed-off-by: Philip Rischel <rischelp@idt.com>
