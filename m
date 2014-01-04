From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v2 0/5] bgmac: add initial support for core rev 4 on ARM BCM47xx
Date: Sat, 4 Jan 2014 23:25:45 +0100
Message-ID: <CACna6rwq-VM9n=UzM6COQiJPkmKevWOM3TVVyM=gHGH2MeOqVw@mail.gmail.com>
References: <1388859238-22808-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:41471 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753656AbaADWZq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 17:25:46 -0500
Received: by mail-ob0-f171.google.com with SMTP id wp18so16997550obc.16
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 14:25:45 -0800 (PST)
In-Reply-To: <1388859238-22808-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014/1/4 Hauke Mehrtens <hauke@hauke-m.de>:
> This adds support for core rev 4 and ARM BCM47XX. I still have proble=
ms
> with the DMA controller on the BCM4707 and I do not have a BCM53018.
> Some packages are getting corrupted on TX, some are getting duplicate=
d
> on TX and so on on a BCM4707, I am still trying to fix this.
>
> v2: add changed suggested by Rafa=C5=82
>
> Hauke Mehrtens (5):
>   bcma: export bcma_find_core_unit()
>   bgmac: initialize the DMA controller of core rev >=3D 4
>   bgmac: add support for new BGMAC_CMDCFG_SR position on core rev >=3D=
 4
>   bgmac: reset all cores on Northstar SoC

=46or patches 1-4:
Acked-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>

5/5 under discussion
