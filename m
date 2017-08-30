From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 0/4] SRIOV VF VGT+ and violation counters support
Date: Wed, 30 Aug 2017 21:33:18 +0300
Message-ID: <CALzJLG9FDh9XJKOGBxqxLqrJf3FSFxX8dZRLALxJRA7G-NQBBA@mail.gmail.com>
References: <20170827110618.20599-1-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Eugenia Emantayev <eugenia@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:35561 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751980AbdH3Sdk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 14:33:40 -0400
Received: by mail-lf0-f43.google.com with SMTP id g18so8406487lfl.2
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 11:33:40 -0700 (PDT)
In-Reply-To: <20170827110618.20599-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 27, 2017 at 2:06 PM, Saeed Mahameed <saeedm@mellanox.com> wrote:
> Hi Dave
>
> This series provides two security SRIOV related features (VGT+ and VF violation counters).
>
> VGT+ is a security feature that gives the administrator the ability of controlling
> the allowed VGT vlan IDs list that can be transmitted/received from/to the VF.
> The allowed VGT vlan IDs list is called "trunk".
>

Dave, I would like to drop this series for now since we need to respin
and find a better API to query vlan lists. it seems that it will take
some time for our developer to complete this. So i would like to
submit something else in the meanwhile.

Thanks,
Saeed.
