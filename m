From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH -next] net: dsa: mv88e6xxx: fix non static symbol warnings
Date: Sun, 25 Sep 2016 16:46:19 -0400
Message-ID: <87fuon1zdw.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1474818182-19097-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>, Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:56177 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933812AbcIYUqY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 16:46:24 -0400
In-Reply-To: <1474818182-19097-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wei,

Wei Yongjun <weiyj.lk@gmail.com> writes:

> From: Wei Yongjun <weiyongjun1@huawei.com>
>
> Fixes the following sparse warnings:
>
> drivers/net/dsa/mv88e6xxx/chip.c:219:5: warning:
>  symbol 'mv88e6xxx_port_read' was not declared. Should it be static?
> drivers/net/dsa/mv88e6xxx/chip.c:227:5: warning:
>  symbol 'mv88e6xxx_port_write' was not declared. Should it be static?
>
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
