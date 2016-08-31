From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next V4 1/4] net/ip_tunnels: Introduce
 tunnel_id_to_key32() and key32_to_tunnel_id()
Date: Wed, 31 Aug 2016 17:04:55 +0200
Message-ID: <20160831150455.GA1986@nanopsycho>
References: <1472647584-6713-1-git-send-email-hadarh@mellanox.com>
 <1472647584-6713-2-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:32937 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935612AbcHaPE7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 11:04:59 -0400
Received: by mail-wm0-f66.google.com with SMTP id w207so3853671wmw.0
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 08:04:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1472647584-6713-2-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 31, 2016 at 02:46:21PM CEST, hadarh@mellanox.com wrote:
>From: Amir Vadai <amir@vadai.me>
>
>Add utility functions to convert a 32 bits key into a 64 bits tunnel and
>vice versa.
>These functions will be used instead of cloning code in GRE and VXLAN,
>and in tc act_iptunnel which will be introduced in a following patch in
>this patchset.
>
>Signed-off-by: Amir Vadai <amir@vadai.me>
>Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
>Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
>Acked-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
