From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [PATCH] cpsw: ethtool: add support for nway reset
Date: Wed, 30 Nov 2016 10:31:30 +0100
Message-ID: <CAGm1_ktxyxVxYdF0Aq-Nv2rVGjEccPsGRZSXHBOE9egybiV1Lg@mail.gmail.com>
References: <1480326472-5849-1-git-send-email-yegorslists@googlemail.com> <20161129.194158.1482957574907674651.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        "N, Mugunthan V" <mugunthanvnm@ti.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f169.google.com ([209.85.217.169]:35038 "EHLO
        mail-ua0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754166AbcK3Jbw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 04:31:52 -0500
In-Reply-To: <20161129.194158.1482957574907674651.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, Nov 30, 2016 at 1:41 AM, David Miller <davem@davemloft.net> wrote:
> From: yegorslists@googlemail.com
> Date: Mon, 28 Nov 2016 10:47:52 +0100
>
>> From: Yegor Yefremov <yegorslists@googlemail.com>
>>
>> This patch adds support for ethtool's '-r' command. Restarting
>> N-WAY negotiation can be useful to activate newly changed EEE
>> settings etc.
>>
>> Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
>
> This doesn't apply cleanly to net-next.

My previous patch [1] doesn't show up in net-next. This could explain,
why nway patch doesn't apply.
Should I resend them both as series?

[1] http://marc.info/?l=linux-omap&m=148036822211869&w=2

Yegor
