From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next] net: ipv6: Add sysctl for minimum prefix len
 acceptable in RIOs.
Date: Wed, 22 Mar 2017 19:13:51 +0900
Message-ID: <CAKD1Yr0RRiTbxuWiDPCtem2jcVcZ2BU6=GxyrkTFAhgogYWhBA@mail.gmail.com>
References: <20170322091904.73420-1-jscherpelz@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Erik Kline <ek@google.com>
To: Joel Scherpelz <jscherpelz@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:34952 "EHLO
        mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758777AbdCVKOs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 06:14:48 -0400
Received: by mail-vk0-f42.google.com with SMTP id r69so10401402vke.2
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 03:14:12 -0700 (PDT)
In-Reply-To: <20170322091904.73420-1-jscherpelz@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 22, 2017 at 6:19 PM, Joel Scherpelz <jscherpelz@google.com> wrote:
> It is useful to prevent misconfigurations from
> unintentionally blackholing too much of the IPv6 address space
> (e.g., home routers announcing RIOs for fc00::/7, which is
> incorrect).
>
> Signed-off-by: Joel Scherpelz <jscherpelz@google.com>

Acked-by: Lorenzo Colitti <lorenzo@google.com>
