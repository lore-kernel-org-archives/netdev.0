From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next v10 1/3] netdevice: Add offload statistics ndo
Date: Sat, 17 Sep 2016 13:50:14 +0300
Message-ID: <0FD61B43-489D-4FDE-AC85-4B113A12B1F4@cumulusnetworks.com>
References: <1474031138-2065-1-git-send-email-jiri@resnulli.us> <1474031138-2065-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, nogahf@mellanox.com,
        Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
        yotamg@mellanox.com, ogerlitz@mellanox.com,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        linville@tuxdriver.com, tgraf@suug.ch,
        Andy Gospodarek <gospo@cumulusnetworks.com>, sfeldma@gmail.com,
        sd@queasysnail.net, eranbe@mellanox.com, ast@plumgrid.com,
        edumazet@google.com, hannes@stressinduktion.org,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36931 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933668AbcIQKuS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 06:50:18 -0400
Received: by mail-wm0-f47.google.com with SMTP id k186so81307177wmd.0
        for <netdev@vger.kernel.org>; Sat, 17 Sep 2016 03:50:18 -0700 (PDT)
In-Reply-To: <1474031138-2065-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Sep 16, 2016, at 4:05 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> 
> From: Nogah Frankel <nogahf@mellanox.com>
> 
> Add a new ndo to return statistics for offloaded operation.
> Since there can be many different offloaded operation with many
> stats types, the ndo gets an attribute id by which it knows which
> stats are wanted. The ndo also gets a void pointer to be cast according
> to the attribute id.
> 
> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> include/linux/netdevice.h | 12 ++++++++++++
> 1 file changed, 12 insertions(+)
> 

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
