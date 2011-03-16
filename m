From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6 6/6] net: introduce rx_handler results and
 logic around that
Date: Wed, 16 Mar 2011 12:53:06 -0700 (PDT)
Message-ID: <20110316.125306.70202132.davem@davemloft.net>
References: <4D7B7403.6050402@gmail.com>
	<4D7B7453.5040606@gmail.com>
	<20110312133643.GB2899@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.2p.debian@gmail.com, netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48023
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753804Ab1CPTw2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2011 15:52:28 -0400
In-Reply-To: <20110312133643.GB2899@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jiri Pirko <jpirko@redhat.com>
Date: Sat, 12 Mar 2011 14:36:44 +0100

> Sat, Mar 12, 2011 at 02:25:39PM CET, nicolas.2p.debian@gmail.com wrot=
e:
>>Le 12/03/2011 14:24, Nicolas de Peslo=FCan a =E9crit :
>>>Le 12/03/2011 14:14, Jiri Pirko a =E9crit :
>>>>This patch allows rx_handlers to better signalize what to do next t=
o
>>>>it's caller. That makes skb->deliver_no_wcard no longer needed.
>>>>
>>>>kernel-doc for rx_handler_result is taken from Nicolas' patch.
>>>>
>>>>Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>>>>eviewed-by: Nicolas de Peslo=FCan<nicolas.2p.debian@free.fr>
>>>
>>>Typo in [R]eviewed-by and missing space between Peslo=FCan and <nico=
las.
>>>
>>>Nicolas.
>>
>>Only the missing R in Reviewed-by:. The space was removed by my mail =
client, sorry.
>=20
> Copypaste err :( Sorry..
>=20
> Dave would you please add "R" before you apply. Many thanks.

I will, thanks.

Applied.
