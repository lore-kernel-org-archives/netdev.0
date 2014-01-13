From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH net-next] bgmac: propagate error codes in bgmac_probe()
Date: Mon, 13 Jan 2014 06:58:46 +0100
Message-ID: <CACna6rw+vH+aPpf3_Rsd=QYHS3s=9Oq+MZV_CnKq1xpXyKzEtQ@mail.gmail.com>
References: <1389582355-27514-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Nathan Hintz <nlhintz@hotmail.com>, sd@queasysnail.net,
	bhutchings@solarflare.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:65098 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219AbaAMF6r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 00:58:47 -0500
Received: by mail-ob0-f175.google.com with SMTP id uz6so7196293obc.34
        for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 21:58:46 -0800 (PST)
In-Reply-To: <1389582355-27514-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014/1/13 Florian Fainelli <f.fainelli@gmail.com>:
> bgmac_mii_register() and register_netdev() both return appropriate er=
ror
> codes for the failures they would encounter, propagate this error cod=
e
> instead of overriding the value with -ENOTSUPP which is not the corre=
ct
> error code to return.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Acked-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>

--=20
Rafa=C5=82
