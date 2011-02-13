From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6] net: remove the unnecessary dance around
 skb_bond_should_drop
Date: Sun, 13 Feb 2011 11:07:58 -0800 (PST)
Message-ID: <20110213.110758.52186282.davem@davemloft.net>
References: <20110212104605.GA2786@psychotron.redhat.com>
	<4D568251.7000305@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jpirko@redhat.com, netdev@vger.kernel.org
To: nicolas.2p.debian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46764
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754738Ab1BMTHW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Feb 2011 14:07:22 -0500
In-Reply-To: <4D568251.7000305@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com>
Date: Sat, 12 Feb 2011 13:51:29 +0100

> Le 12/02/2011 11:46, Jiri Pirko a =E9crit :
>> No need to check (master) twice and to drive in and out the header
>> file.
>>
>> Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>=20
> Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

Applied.
