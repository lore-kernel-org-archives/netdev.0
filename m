From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next V4 2/4] net/dst: Utility functions to build
 dst_metadata without supplying an skb
Date: Wed, 31 Aug 2016 17:07:01 +0200
Message-ID: <20160831150700.GB1986@nanopsycho>
References: <1472647584-6713-1-git-send-email-hadarh@mellanox.com>
 <1472647584-6713-3-git-send-email-hadarh@mellanox.com>
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
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35779 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935677AbcHaPHE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 11:07:04 -0400
Received: by mail-wm0-f66.google.com with SMTP id i5so8058049wmg.2
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 08:07:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1472647584-6713-3-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 31, 2016 at 02:46:22PM CEST, hadarh@mellanox.com wrote:
>From: Amir Vadai <amir@vadai.me>
>
>Extract __ip_tun_set_dst() and __ipv6_tun_set_dst() out of
>ip_tun_rx_dst() and ipv6_tun_rx_dst(), to be used without supplying an
>skb.
>
>Signed-off-by: Amir Vadai <amir@vadai.me>
>Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
