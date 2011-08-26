From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFT PATCH v3 00/12] Cleanup and extension of netdev features
Date: Fri, 26 Aug 2011 09:43:19 -0700
Message-ID: <4E57CD27.8090500@candelatech.com>
References: <cover.1308758435.git.mirq-linux@rere.qmqm.pl>	<4E569CC8.9040605@candelatech.com> <20110826.124107.1302583595703798441.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=EUC-KR
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:36025 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753985Ab1HZQor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 12:44:47 -0400
In-Reply-To: <20110826.124107.1302583595703798441.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2011 09:41 AM, David Miller wrote:
> From: Ben Greear<greearb@candelatech.com>
> Date: Thu, 25 Aug 2011 12:04:40 -0700
>=20
>> On 06/22/2011 09:04 AM, Micha=A9=A9 Miros=A9=A9aw wrote:
>>> v3 of a feature handling cleanup and extension series. For testing,
>>> you
>>> might want user-space ethtool patched with:
>>>
>>> http://patchwork.ozlabs.org/patch/96374/
>>
>> It looks like this is not in net-next yet...any hope of this
>> going in soon?
>=20
> Why would it go into net-next?  It's not a kernel patch, it's a patch
> for the ethool userland utility.

I meant the kernel bits in that patch series, not the link.

Sorry for not snipping enough.

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
