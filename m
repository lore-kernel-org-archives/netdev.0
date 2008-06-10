From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [RFC][PATCH 3/3] IPv4:Check IP_MULTICAST_LOOP option value
Date: Tue, 10 Jun 2008 16:32:10 +0800
Message-ID: <484E3C0A.1000808@cn.fujitsu.com>
References: <484E3293.8000507@cn.fujitsu.com> <20080610.171527.86317043.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52832 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751096AbYFJIdX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 04:33:23 -0400
In-Reply-To: <20080610.171527.86317043.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E =E5=86=99=E9=81=
=93:
> In article <484E3293.8000507@cn.fujitsu.com> (at Tue, 10 Jun 2008 15:=
51:47 +0800), Shan Wei <shanwei@cn.fujitsu.com> says:
>=20
>> The IP_MULTICAST_LOOP option can only be set with o or 1. When=20
>> other valuse are set, the kernel should return an error of EINVAL.
>>
>> In addition, the option should not be uesd by SOCK_STREAM type,
>> same as IP_MULTICAST_IF, IP_MULTICAST_TTL.
>>  =20
>> But the kernel doesn't check them.
>=20
> Is there any standard reference about this?
>=20
I have not found it.
But, the IP_MULTICAST_LOOP option is same as IPV6_MULTICAST_LOOP.

> --yoshfuji
>=20
>=20
>=20


