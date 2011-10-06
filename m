From: David <asweisun@qq.com>
Subject: Re: A new 40G Network driver ready to submit to the kernel tree
Date: Thu, 6 Oct 2011 23:06:01 +0800
Message-ID: <A1F7F0AE-C9F9-414B-9417-FAC69FD8AC39@qq.com>
References: <4E8CE4A0.4060202@oracle.com>
Mime-Version: 1.0 (iPhone Mail 8L1)
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joyce Yu - System Software <joyce.yu@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg52.qq.com ([64.71.138.43]:51015 "HELO smtpbg52.qq.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751420Ab1JFPHP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 11:07:15 -0400
In-Reply-To: <4E8CE4A0.4060202@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


=D4=DA 2011-10-6=A3=AC7:13=A3=ACJoyce Yu - System Software <joyce.yu@or=
acle.com> =D0=B4=B5=C0=A3=BA

>=20
>=20
> I have a new 40G Network driver ready to submit to the kernel tree. T=
he driver has been ported to latest linux-3.0-rc5 and net-2.6-353e5c9 t=
ree. The driver versions for 2.6.18 and 2.6.32 based kernel have been f=
ully tested and released to the customer. Shall I just send the driverx=
x.c and driverxx.h for net-2.6-353e5c9 and linux-3.0-rc5 to this alias?=
 =20

net tree and linux tree are just only for bug fix. New features or new =
drivers should be merged from net-next tree which locates at Github sit=
e.=20

Shan Wei
>=20
> Thanks,
> Joyce
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20
