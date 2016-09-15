From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH -next] net: dsa: bcm_sf2: Fix non static symbol warning
Date: Wed, 14 Sep 2016 19:46:08 -0700
Message-ID: <CAGVrzcapcSVYX+pQaL8Qme8rp8Qbsod=SEFfALQmUWjMBH6Wxg@mail.gmail.com>
References: <1473906253-1424-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@mellanox.com>,
        Wei Yongjun <weiyongjun1@huawei.com>,
        netdev <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:35413 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755955AbcIOCqu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 22:46:50 -0400
Received: by mail-it0-f42.google.com with SMTP id r192so74533604ita.0
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 19:46:49 -0700 (PDT)
In-Reply-To: <1473906253-1424-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-09-14 19:24 GMT-07:00 Wei Yongjun <weiyj.lk@gmail.com>:
> From: Wei Yongjun <weiyongjun1@huawei.com>
>
> Fixes the following sparse warning:
>
> drivers/net/dsa/bcm_sf2.c:963:19: warning:
>  symbol 'bcm_sf2_io_ops' was not declared. Should it be static?
>
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
