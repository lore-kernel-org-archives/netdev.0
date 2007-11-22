From: Laszlo Attila Toth <panther@balabit.hu>
Subject: Re: [PATCHv6 0/3] Interface group patches
Date: Thu, 22 Nov 2007 10:05:53 +0100
Message-ID: <47454671.6020905@balabit.hu>
References: <4742E68C.2000802@balabit.hu>	<20071120.134242.177093096.davem@davemloft.net>	<47437B12.9090009@trash.net> <20071120.171743.04294220.davem@davemloft.net>
Reply-To: panther@balabit.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, jengelh@computergmbh.de, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20071120.171743.04294220.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller =EDrta:
> From: Patrick McHardy <kaber@trash.net>
> Date: Wed, 21 Nov 2007 01:25:54 +0100
>=20
>> I'm working on the incremental ruleset changing API BTW :)
>> One of the changes will be that interface matching is not
>> a default part of every rule, and without wildcards it will
>> use the ifindex. But since the cost of this feature seems
>> pretty low, I don't see a compelling reason against it.
>=20
> Fair enough :)
>=20

If this means the patch is ok, please apply it. Thanks.

--
Attila
-
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
