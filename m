From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: switchdev: Use an helper to clear
 forward mark
Date: Sun, 3 Sep 2017 18:02:21 +0300
Message-ID: <71444c6f-d33f-3bef-9e1d-d34f7fd333b4@cumulusnetworks.com>
References: <20170903144413.21946-1-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, stephen@networkplumber.org,
        yotamg@mellanox.com, bridge@lists.linux-foundation.org,
        mlxsw@mellanox.com
To: Ido Schimmel <idosch@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36486 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752878AbdICPCZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 11:02:25 -0400
Received: by mail-wm0-f51.google.com with SMTP id i145so7937547wmf.1
        for <netdev@vger.kernel.org>; Sun, 03 Sep 2017 08:02:24 -0700 (PDT)
In-Reply-To: <20170903144413.21946-1-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/09/17 17:44, Ido Schimmel wrote:
> Instead of using ifdef in the C file.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Suggested-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Tested-by: Yotam Gigi <yotamg@mellanox.com>
> ---
>  net/bridge/br_device.c  | 4 +---
>  net/bridge/br_private.h | 9 +++++++++
>  2 files changed, 10 insertions(+), 3 deletions(-)
> 

Thanks for following up on this!

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
