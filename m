From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: dont use netdev_alloc_skb()
Date: Thu, 14 Oct 2010 11:25:52 -0700 (PDT)
Message-ID: <20101014.112552.112586402.davem@davemloft.net>
References: <20101014.103914.193713537.davem@davemloft.net>
	<1287080255.22035.2.camel@lb-tlvb-eilong.il.broadcom.com>
	<1287080420.2712.102.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eilong@broadcom.com, vladz@broadcom.com, therbert@google.com,
	netdev@vger.kernel.org, mchan@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38009
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754730Ab0JNSZa convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Oct 2010 14:25:30 -0400
In-Reply-To: <1287080420.2712.102.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 14 Oct 2010 20:20:20 +0200

> Le jeudi 14 octobre 2010 =E0 20:17 +0200, Eilon Greenstein a =E9crit =
:
>> On Thu, 2010-10-14 at 10:39 -0700, David Miller wrote:
>> > From: "Vladislav Zolotarov" <vladz@broadcom.com>
>> > Date: Tue, 12 Oct 2010 02:12:41 -0700
>> >=20
>> > > Dave, if it can wait till tomorrow, I'd like to ask u to wait fo=
r Eilon's
>> > > final ACK.
>> >=20
>> > Ok, but it is two days later now :-)
>> >=20
>>=20
>> I was under the impression that the current path is to revert
>> b30973f877fea1a3fb84e05599890fcc082a88e5 instead of the original thr=
ead.
>> Eric - do you still want to apply the original patch from this threa=
d?
>=20
> No, this patch is not needed, if the generic one is considered.

Ok.
