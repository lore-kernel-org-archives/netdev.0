From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [PATCH] cpsw: ethtool: add support for nway reset
Date: Mon, 28 Nov 2016 16:25:38 +0100
Message-ID: <CAGm1_kssM4qZzrLKf=NZDX7Ts9ZHHcnsu_0DNy3Ltwy0XZopBQ@mail.gmail.com>
References: <1480326472-5849-1-git-send-email-yegorslists@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        "N, Mugunthan V" <mugunthanvnm@ti.com>,
        David Miller <davem@davemloft.net>,
        Yegor Yefremov <yegorslists@googlemail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f181.google.com ([209.85.217.181]:33511 "EHLO
        mail-ua0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933166AbcK1P0A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 10:26:00 -0500
In-Reply-To: <1480326472-5849-1-git-send-email-yegorslists@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 10:47 AM,  <yegorslists@googlemail.com> wrote:
> From: Yegor Yefremov <yegorslists@googlemail.com>
>
> This patch adds support for ethtool's '-r' command. Restarting
> N-WAY negotiation can be useful to activate newly changed EEE
> settings etc.
>
> Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>

This patch applies on top of
http://marc.info/?l=linux-netdev&m=148032251729251&w=2

Yegor
