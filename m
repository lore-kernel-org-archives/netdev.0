From: =?UTF-8?Q?Nie=C5=9Bcierowicz_Adam?= <adam.niescierowicz@justnet.pl>
Subject: Re: 3.4.1 and 3.5-rc1 Packet lost at 250Mb/s
Date: Mon, 08 Oct 2012 14:06:43 +0200
Message-ID: <59e3b47d13d2c9081236dd5f82c3d312@justnet.pl>
References: <409ac8b30a6994028562e1a159ac60aa@justnet.pl>
 <1349677373.21172.2756.camel@edumazet-glaptop>
 <9819d6943a7cfddfc8fa49217aa4842e@justnet.pl>
 <1349689640.21172.3008.camel@edumazet-glaptop>
 <80bb011e8f1289218087633fd7b115ea@justnet.pl> <5072C063.6000302@tomt.net>
Reply-To: <adam.niescierowicz@justnet.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: Andre Tomt <andre@tomt.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-91.230.163.37.ltv.pl ([91.230.163.37]:37465 "EHLO
	mail.justnet.pl" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1750799Ab2JHMG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 08:06:56 -0400
In-Reply-To: <5072C063.6000302@tomt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 08.10.2012 14:00, Andre Tomt napisa=C5=82(a):

> On 08. okt. 2012 12:49, Nie=C5=9Bcierowicz Adam wrote:
>
>> W dniu 08.10.2012 11:47, Eric Dumazet napisa=C5=82(a):
>>
>>> Anyway you dont say where are drops, (ifconfig give us very few
>>> drops)
>> you can see no losses(drop), but a temporary decline in traffic on=20
>> the
>> interface to 0kb/s
>
> This sounds very familiar, could it be something similar to:
> http://marc.info/?l=3Dlinux-netdev&m=3D134594936016796&w=3D3 [1]
>
> The chip seems to be of the same family (though not model)

In fact it looks similarly.
Here the problem has performed in kernel 3.4.1, 3.5-rcX, and 3.6
