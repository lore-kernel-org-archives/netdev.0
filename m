From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH v2] sh: sh_eth: Add support SH7734
Date: Mon, 26 Mar 2012 14:00:59 +0900
Message-ID: <4F6FF80B.5080409@renesas.com>
References: <1332478533-17382-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <20120323.145243.112333113762306752.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor2.renesas.com ([210.160.252.172]:40881 "EHLO
	relmlor2.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694Ab2CZEzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 00:55:06 -0400
Received: from relmlir2.idc.renesas.com ([10.200.68.152])
 by relmlor2.idc.renesas.com ( SJSMS)
 with ESMTP id <0M1H00EWL6ZS2T30@relmlor2.idc.renesas.com> for
 netdev@vger.kernel.org; Mon, 26 Mar 2012 13:55:04 +0900 (JST)
Received: from relmlac3.idc.renesas.com ([10.200.69.23])
 by relmlir2.idc.renesas.com ( SJSMS)
 with ESMTP id <0M1H00M726ZSXEG0@relmlir2.idc.renesas.com> for
 netdev@vger.kernel.org; Mon, 26 Mar 2012 13:55:04 +0900 (JST)
In-reply-to: <20120323.145243.112333113762306752.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller =E3=81=95=E3=82=93=E3=81=AF=E6=9B=B8=E3=81=8D=E3=81=BE=E3=81=
=97=E3=81=9F:
> From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> Date: Fri, 23 Mar 2012 13:55:33 +0900
>=20
>> Add define of SH7734 register and sh_eth_reset_hw_crc function.
>>
>> V2: Do not split line of #if defined.
>>
>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
>=20
> This patch does not apply to the current tree.
>=20

Sorry, I rebased and re-send.

Nobuhiro
