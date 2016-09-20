From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Tue, 20 Sep 2016 15:37:31 -0700
Message-ID: <1474411051.23058.42.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
         <1474408824-418864-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com,
        tariqt@mellanox.com, bblanco@plumgrid.com,
        alexei.starovoitov@gmail.com, brouer@redhat.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34318 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753383AbcITWhd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 18:37:33 -0400
Received: by mail-pf0-f174.google.com with SMTP id p64so11762134pfb.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 15:37:33 -0700 (PDT)
In-Reply-To: <1474408824-418864-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-20 at 15:00 -0700, Tom Herbert wrote:

> diff --git a/net/core/xdp.c b/net/core/xdp.c
> new file mode 100644
> index 0000000..815ead8
> --- /dev/null
> +++ b/net/core/xdp.c
> @@ -0,0 +1,211 @@
> +/*
> + * Kernel Connection Multiplexor
> + *
> + * Copyright (c) 2016 Tom Herbert <tom@herbertland.com>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + */


Too much copy/paste Tom :)
