From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH] net/sh-eth: Add support selecting MII function for SH7734
 and R8A7740
Date: Tue, 12 Jun 2012 16:28:20 +0900
Message-ID: <4FD6EF94.9000906@renesas.com>
References: <1339135311-1896-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <20120611.164717.1390327462404819704.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor4.renesas.com ([210.160.252.174]:48307 "EHLO
	relmlor4.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696Ab2FLHUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 03:20:37 -0400
Received: from relmlir4.idc.renesas.com ([10.200.68.154])
 by relmlor4.idc.renesas.com ( SJSMS)
 with ESMTP id <0M5H00FYATQC4LE0@relmlor4.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 12 Jun 2012 16:20:36 +0900 (JST)
Received: from relmlac2.idc.renesas.com ([10.200.69.22])
 by relmlir4.idc.renesas.com ( SJSMS)
 with ESMTP id <0M5H003EATQCCY70@relmlir4.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 12 Jun 2012 16:20:36 +0900 (JST)
In-reply-to: <20120611.164717.1390327462404819704.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller =E3=81=95=E3=82=93=E3=81=AF=E6=9B=B8=E3=81=8D=E3=81=BE=E3=81=
=97=E3=81=9F:
> From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> Date: Fri,  8 Jun 2012 15:01:51 +0900
>=20
>> +	unsigned select_mii:1;	/* EtherC have RMII_MII (MII select registe=
r) */
>=20
> Nothing tests this value.
>=20

Sorry, I sent old patch. I will sent new patch soon.
Best regards,
   Nobuhiro
