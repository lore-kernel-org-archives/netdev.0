From: Andre Tomt <andre@tomt.net>
Subject: Re: 3.4.1 and 3.5-rc1 Packet lost at 250Mb/s
Date: Mon, 08 Oct 2012 14:00:35 +0200
Message-ID: <5072C063.6000302@tomt.net>
References: <409ac8b30a6994028562e1a159ac60aa@justnet.pl> <1349677373.21172.2756.camel@edumazet-glaptop> <9819d6943a7cfddfc8fa49217aa4842e@justnet.pl> <1349689640.21172.3008.camel@edumazet-glaptop> <80bb011e8f1289218087633fd7b115ea@justnet.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: adam.niescierowicz@justnet.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from catastrophix.ugh.no ([178.79.162.34]:36493 "EHLO
	catastrophix.ugh.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799Ab2JHMIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 08:08:23 -0400
In-Reply-To: <80bb011e8f1289218087633fd7b115ea@justnet.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08. okt. 2012 12:49, Nie=C5=9Bcierowicz Adam wrote:
> W dniu 08.10.2012 11:47, Eric Dumazet napisa=C5=82(a):
>> Anyway you dont say where are drops, (ifconfig give us very few drop=
s)
>
> you can see no losses(drop), but a temporary decline in traffic on th=
e
> interface to 0kb/s

This sounds very familiar, could it be something similar to:
http://marc.info/?l=3Dlinux-netdev&m=3D134594936016796&w=3D3

The chip seems to be of the same family (though not model)
