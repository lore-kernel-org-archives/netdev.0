From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH v2] net/sh-eth: Add support selecting MII function for
 SH7734 and R8A7740
Date: Tue, 26 Jun 2012 12:32:00 +0900
Message-ID: <4FE92D30.1080209@renesas.com>
References: <1339486142-32480-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <20120612.002954.1384327664115800772.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor1.renesas.com ([210.160.252.171]:63339 "EHLO
	relmlor1.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756197Ab2FZDYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 23:24:00 -0400
Received: from relmlir1.idc.renesas.com ([10.200.68.151])
 by relmlor1.idc.renesas.com ( SJSMS)
 with ESMTP id <0M67003PBG3YNQ80@relmlor1.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 26 Jun 2012 12:23:58 +0900 (JST)
Received: from relmlac4.idc.renesas.com ([10.200.69.24])
 by relmlir1.idc.renesas.com (SJSMS)
 with ESMTP id <0M67000M4G3YJT60@relmlir1.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 26 Jun 2012 12:23:58 +0900 (JST)
In-reply-to: <20120612.002954.1384327664115800772.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller =E3=81=95=E3=82=93=E3=81=AF=E6=9B=B8=E3=81=8D=E3=81=BE=E3=81=
=97=E3=81=9F:
> From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> Date: Tue, 12 Jun 2012 16:29:02 +0900
>=20
>> @@ -492,6 +513,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data=
 =3D {
>>  	.no_trimd	=3D 1,
>>  	.no_ade		=3D 1,
>>  	.tsu		=3D 1,
>> +	.select_mii =3D 1,
>>  };
>> =20
>=20
> Indent this new line consistently with those around it.
>=20
Thank you. I will fix and resend.

Best regards,
   Nobuhiro
