From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: Does Realtek RTL8110S and RTL8100C work ?
Date: Mon, 29 Mar 2010 10:43:21 +0200
Message-ID: <4BB06829.10807@computer.org>
References: <hoab2m$kc0$1@dough.gmane.org> <4BABC170.7080008@computer.org> <hoiqcr$dhl$1@dough.gmane.org> <4BAE1248.70201@computer.org> <hopo00$ibe$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Markus Feldmann <feldmann_markus@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay009.isp.belgacom.be ([195.238.6.176]:56588 "EHLO
	mailrelay009.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754185Ab0C2Inq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 04:43:46 -0400
In-Reply-To: <hopo00$ibe$1@dough.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Markus Feldmann wrote:
> do you knonw who is the maintainer for this network device? Or in whe=
re
> can i get more information?

Markus,

As it happens there is a lot of discussion about stability issues with =
this NIC in recent[1] kernel versions right here on this list at the mo=
ment.

Participants in those discussions include Francois Romieu, Timo Ter=E4s=
 and others. See threads "r8169 mac reading/writing broken", "r8169: fi=
x broken register writes", "r8169: enable 64-bit DMA by default for PCI=
 Express devices".


[1]: more recent than I am using on that machine, which is 2.6.27 (Ubun=
tu 9.04).

Jan
