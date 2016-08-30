From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 2/6] net/mlx5e: Read ETS settings directly from firmware
Date: Tue, 30 Aug 2016 23:34:48 +0300
Message-ID: <CAJ3xEMhqonCOrsOJQ_GOb3DCNW8HHaYPL7GBD4CsGpGzWxkUzA@mail.gmail.com>
References: <1472556595-9286-1-git-send-email-saeedm@mellanox.com> <1472556595-9286-3-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Huy Nguyen <huyn@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33940 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751865AbcH3Ueu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 16:34:50 -0400
Received: by mail-oi0-f66.google.com with SMTP id t127so2820921oie.1
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 13:34:50 -0700 (PDT)
In-Reply-To: <1472556595-9286-3-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 30, 2016 at 2:29 PM, Saeed Mahameed <saeedm@mellanox.com> wrote:
> From: Huy Nguyen <huyn@mellanox.com>
>
> Current implementation does not read the setting
> directly from FW when ieee_getets is called.


what's wrong with that? explain
