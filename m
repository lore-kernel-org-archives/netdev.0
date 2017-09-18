From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 02/12] net: dsa: b53: Make b53_enable_cpu_port() take a port argument
Date: Mon, 18 Sep 2017 17:46:08 -0400
Message-ID: <8760cf3ckf.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170918214128.27896-1-f.fainelli@gmail.com> <20170918214128.27896-3-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:34262 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751411AbdIRVtj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 17:49:39 -0400
In-Reply-To: <20170918214128.27896-3-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> In preparation for future changes allowing the configuring of multiple
> CPU ports, make b53_enable_cpu_port() take a port argument.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks,

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
