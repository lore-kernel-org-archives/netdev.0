From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: relax PKTINFO non local ipv6 udp xmit check
Date: Tue, 30 Aug 2011 15:18:48 -0400 (EDT)
Message-ID: <20110830.151848.1069268137900200160.davem@davemloft.net>
References: <1314570931-6233-1-git-send-email-zenczykowski@gmail.com>
	<20110828.210633.783157755808327582.davem@davemloft.net>
	<CANP3RGdLbc7bM_YUU2MTGkMN0cFSx-xt0xrY1SDN_Ep4Fci-AQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48773 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756373Ab1H3TSx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 15:18:53 -0400
In-Reply-To: <CANP3RGdLbc7bM_YUU2MTGkMN0cFSx-xt0xrY1SDN_Ep4Fci-AQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Tue, 30 Aug 2011 11:50:43 -0700

> On Sun, Aug 28, 2011 at 6:06 PM, David Miller <davem@davemloft.net> w=
rote:
>=20
>> > Allow transparent sockets to be less restrictive about
>> > the source ip of ipv6 udp packets being sent.
>>
>> Applied, thanks a lot.
>>
>=20
> FYI, I don't see this in either git repository:

It's in a repo on my machine at home, I'll push it out to 'net' when I
get home later today :-)
