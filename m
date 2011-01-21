From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: netif_setup_tc() is static
Date: Fri, 21 Jan 2011 13:08:43 -0800 (PST)
Message-ID: <20110121.130843.171501921.davem@davemloft.net>
References: <20110119.234132.176672734.davem@davemloft.net>
	<1295587088.2613.51.camel@edumazet-laptop>
	<4D39C86D.2060209@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, bhutchings@solarflare.com,
	jarkao2@gmail.com, hadi@cyberus.ca, shemminger@vyatta.com,
	tgraf@infradead.org, nhorman@tuxdriver.com, netdev@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43631
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751701Ab1AUVIJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jan 2011 16:08:09 -0500
In-Reply-To: <4D39C86D.2060209@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: John Fastabend <john.r.fastabend@intel.com>
Date: Fri, 21 Jan 2011 09:54:53 -0800

> On 1/20/2011 9:18 PM, Eric Dumazet wrote:
>> Le mercredi 19 janvier 2011 =E0 23:41 -0800, David Miller a =E9crit =
:
>>> From: John Fastabend <john.r.fastabend@intel.com>
>>> Date: Mon, 17 Jan 2011 10:06:04 -0800
>>>
>>>> This patch provides a mechanism for lower layer devices to
>>>> steer traffic using skb->priority to tx queues.
>>>  ...
>>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>>>
>>> Applied.
>>=20
>> Hi John
>>=20
>> Should netif_setup_tc() be static, or is it meant to be exported
>> somehow ?
>>=20
>> [PATCH net-next-2.6] net: netif_setup_tc() is static
>>=20
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> ---
>=20
> Acked-by: John Fastabend <john.r.fastabend@intel.com>

Applied, thanks.
