From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [PATCH] cpsw: ethtool: add support for getting/setting EEE registers
Date: Wed, 23 Nov 2016 15:40:32 +0100
Message-ID: <CAGm1_ks01zBoL_rVPbg=GqxLbm5X+pfvhbbL1X65+JFW2-2_Lw@mail.gmail.com>
References: <1479897248-5923-1-git-send-email-yegorslists@googlemail.com> <CAKoUArn8ndLaaEEr55DNFOqJL1hcRvpZCZ1e7WqhWZiaAHBiNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        Linux OMAP Mailing List <linux-omap@vger.kernel.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        "N, Mugunthan V" <mugunthanvnm@ti.com>
To: Rami Rosen <roszenrami@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:35519 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936461AbcKWOmQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 09:42:16 -0500
In-Reply-To: <CAKoUArn8ndLaaEEr55DNFOqJL1hcRvpZCZ1e7WqhWZiaAHBiNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rami,

On Wed, Nov 23, 2016 at 3:31 PM, Rami Rosen <roszenrami@gmail.com> wrote:
> Hi, Yegor,
>
> Minor comment: these methods should be static.
>
> +int cpsw_get_eee(struct net_device *ndev, struct ethtool_eee *edata)
> +{
> ...
> ...
> +int cpsw_set_eee(struct net_device *ndev, struct ethtool_eee *edata)
> ...

ACK. Fixed in v2.

Thanks.

Yegor
