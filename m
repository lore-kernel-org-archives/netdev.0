From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: UDP-Lite and /proc/net/snmp
Date: Sat, 10 Nov 2007 14:55:21 +0100
Message-ID: <4735B849.4020700@cosmosbay.com>
References: <20071110131428.GA6447@gondor.apana.org.au> <20071110.223243.114494952.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:50091 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214AbXKJN4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Nov 2007 08:56:07 -0500
In-Reply-To: <20071110.223243.114494952.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E a =C3=A9crit :
> In article <20071110131428.GA6447@gondor.apana.org.au> (at Sat, 10 No=
v 2007 21:14:29 +0800), Herbert Xu <herbert@gondor.apana.org.au> says:
>=20
>> It looks like the addition of UDP-Lite has upset netstat:
>>
>> $ netstat -s
>> Ip:
> :
>> Udp:
>>     30 packets received
>>     0 packets to unknown port received.
>>     0 packet receive errors
>>     17 packets sent
>> UdpLite:
>> error parsing /proc/net/snmp: Success
>> $
>>
>> Should we remove it again or let it stay this time?
>=20
> Hmm?  netstat 1.42 (net-tools 1.60) seems fine.
> Which netstat are you using?
>=20

I have the same problem with a netstat 1.42 (debian x86_64 lenny/sid)



