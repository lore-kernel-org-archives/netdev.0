From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 6/9] net/mlx4_en: Adding support of turning off
 link autonegotiation via ethtool
Date: Tue, 17 Jan 2017 09:21:43 +0200
Message-ID: <CAJ3xEMhHDSZ3REvtGpF+Nu-KuG2UZQChs1PV_-U3TiV+UPzEBQ@mail.gmail.com>
References: <1484587805-12666-1-git-send-email-tariqt@mellanox.com>
 <1484587805-12666-7-git-send-email-tariqt@mellanox.com> <CAJ3xEMjEPQv=Agz5Wr-2UEL+iv7nz4NAcpCKY9=C4vs6SfKLLA@mail.gmail.com>
 <DB3PR05MB21933E49B3A1B8CC0C37A32BA7D0@DB3PR05MB219.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Ariel Levkovich <lariel@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:34115 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750817AbdAQHWH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 02:22:07 -0500
Received: by mail-oi0-f51.google.com with SMTP id m124so78304866oif.1
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 23:21:44 -0800 (PST)
In-Reply-To: <DB3PR05MB21933E49B3A1B8CC0C37A32BA7D0@DB3PR05MB219.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 17, 2017 at 1:08 AM, Ariel Levkovich <lariel@mellanox.com> wrote:
> +       MLX4_PTYS_AN_DISABLE_CAP   = 1 << 5,
>
> It's there.

It would be good to spare few words on that aspect in the change log.
