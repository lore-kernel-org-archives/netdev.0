From: David Miller <davem@davemloft.net>
Subject: Re: [RFT PATCH v3 00/12] Cleanup and extension of netdev features
Date: Fri, 26 Aug 2011 12:47:57 -0400 (EDT)
Message-ID: <20110826.124757.1122820419902181640.davem@davemloft.net>
References: <4E569CC8.9040605@candelatech.com>
	<20110826.124107.1302583595703798441.davem@davemloft.net>
	<4E57CD27.8090500@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58583 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753985Ab1HZQtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 12:49:24 -0400
In-Reply-To: <4E57CD27.8090500@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ben Greear <greearb@candelatech.com>
Date: Fri, 26 Aug 2011 09:43:19 -0700

> On 08/26/2011 09:41 AM, David Miller wrote:
>> From: Ben Greear<greearb@candelatech.com>
>> Date: Thu, 25 Aug 2011 12:04:40 -0700
>>=20
>>> On 06/22/2011 09:04 AM, Micha=A9=A9 Miros=A9=A9aw wrote:
>>>> v3 of a feature handling cleanup and extension series. For testing=
,
>>>> you
>>>> might want user-space ethtool patched with:
>>>>
>>>> http://patchwork.ozlabs.org/patch/96374/
>>>
>>> It looks like this is not in net-next yet...any hope of this
>>> going in soon?
>>=20
>> Why would it go into net-next?  It's not a kernel patch, it's a patc=
h
>> for the ethool userland utility.
>=20
> I meant the kernel bits in that patch series, not the link.

It's possible that if you go look at the threads about those kernel
patches you're find out the reason.
