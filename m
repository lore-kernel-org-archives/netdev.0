From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v5 net-next] net: systemport: Support 64bit statistics
Date: Sun, 30 Jul 2017 20:45:46 -0700
Message-ID: <BB135D88-36F0-40AB-84D0-EF3A36B5AC2F@gmail.com>
References: <1501459275-7635-1-git-send-email-jqiaoulk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
To: "Jianming.qiao" <jqiaoulk@gmail.com>, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33703 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751674AbdGaDrr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 23:47:47 -0400
Received: by mail-pg0-f66.google.com with SMTP id u185so6966694pgb.0
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2017 20:47:47 -0700 (PDT)
In-Reply-To: <1501459275-7635-1-git-send-email-jqiaoulk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On July 30, 2017 5:01:15 PM PDT, "Jianming=2Eqiao" <jqiaoulk@gmail=2Ecom> w=
rote:
>When using Broadcom Systemport device in 32bit Platform, ifconfig can
>only report up to 4G tx,rx status, which will be wrapped to 0 when the
>number of incoming or outgoing packets exceeds 4G, only taking
>around 2 hours in busy network environment (such as streaming)=2E
>Therefore, it makes hard for network diagnostic tool to get reliable
>statistical result, so the patch is used to add 64bit support for
>Broadcom Systemport device in 32bit Platform=2E
>
>Signed-off-by: Jianming=2Eqiao <kiki-good@hotmail=2Ecom>

Reviewed-by: Florian Fainelli <f=2Efainelli@gmail=2Ecom>

--=20
Florian
