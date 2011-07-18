From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/24] bnx2x: New FW and support for 578xx
Date: Mon, 18 Jul 2011 12:09:58 +0200
Message-ID: <1310983798.5756.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <201106141213.34576.vladz@broadcom.com>
	 <BD3F7F1EFBA6D54DB056C4FFA451400809D2C13864@SJEXCHCCR01.corp.ad.broadcom.com>
	 <201106141432.32257.vladz@broadcom.com>
	 <20110614.115402.426774711287563448.davem@davemloft.net>
	 <1310982501.5756.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1310982917.8205.1.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Vladislav Zolotarov <vladz@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	"Bhanu (Venkata Bhanu Prakash) Gollapudi" <bprakash@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Yaniv Rosner <yaniv.rosner@broadcom.com>,
	"dwmw2@infradead.org" <dwmw2@infradead.org>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53868 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754132Ab1GRKKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 06:10:08 -0400
Received: by wwe5 with SMTP id 5so3021531wwe.1
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2011 03:10:07 -0700 (PDT)
In-Reply-To: <1310982917.8205.1.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 18 juillet 2011 =C3=A0 12:55 +0300, Eilon Greenstein a =C3=A9c=
rit :
> On Mon, 2011-07-18 at 02:48 -0700, Eric Dumazet wrote:

> >=20
> > Hmm, I probably missed something obvious, but my dev machine (one H=
PG6
> > blade in a distant datacenter) fails to init its bnx2x interfaces w=
ith
> > current net-next-2.6
> >=20
> > Can't load firmware file bnx2x/bnx2x-e1h-7.0.23.0.fw
>=20
> You are missing the FW git from
> git://git.kernel.org/pub/scm/linux/kernel/git/dwmw2/linux-firmware.gi=
t
>=20
> You need to get it separately since the FW is not part of the kernel =
git
> now.

I knew it was obvious, thanks Eilon, this works better now !


