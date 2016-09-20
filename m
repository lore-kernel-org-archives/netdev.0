From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Tue, 20 Sep 2016 15:40:33 -0700
Message-ID: <CALx6S36kHiu+kNguKhQAqHo2q_j5zQeLgA7TiJx9BBEP9AmhdQ@mail.gmail.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
 <1474408824-418864-2-git-send-email-tom@herbertland.com> <1474411051.23058.42.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:33590 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752961AbcITWke (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 18:40:34 -0400
Received: by mail-qt0-f193.google.com with SMTP id p47so1005830qtc.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 15:40:34 -0700 (PDT)
In-Reply-To: <1474411051.23058.42.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 3:37 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2016-09-20 at 15:00 -0700, Tom Herbert wrote:
>
>> diff --git a/net/core/xdp.c b/net/core/xdp.c
>> new file mode 100644
>> index 0000000..815ead8
>> --- /dev/null
>> +++ b/net/core/xdp.c
>> @@ -0,0 +1,211 @@
>> +/*
>> + * Kernel Connection Multiplexor
>> + *
>> + * Copyright (c) 2016 Tom Herbert <tom@herbertland.com>
>> + *
>> + * This program is free software; you can redistribute it and/or modify
>> + * it under the terms of the GNU General Public License version 2
>> + * as published by the Free Software Foundation.
>> + */
>
>
> Too much copy/paste Tom :)
>
If this is you're only complaint Eric I'll be quite impressed ;-)

>
