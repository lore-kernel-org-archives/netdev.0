From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next V4 2/4] net/dst: Utility functions to build
 dst_metadata without supplying an skb
Date: Wed, 31 Aug 2016 20:11:32 +0300
Message-ID: <20160831201132.47d11c68@halley>
References: <1472647584-6713-1-git-send-email-hadarh@mellanox.com>
        <1472647584-6713-3-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37713 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161189AbcHaRLz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 13:11:55 -0400
Received: by mail-wm0-f47.google.com with SMTP id i5so101683598wmg.0
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 10:11:55 -0700 (PDT)
In-Reply-To: <1472647584-6713-3-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Aug 2016 15:46:22 +0300 Hadar Hen Zion <hadarh@mellanox.com> wrote:
> From: Amir Vadai <amir@vadai.me>
> 
> Extract __ip_tun_set_dst() and __ipv6_tun_set_dst() out of
> ip_tun_rx_dst() and ipv6_tun_rx_dst(), to be used without supplying an
> skb.
> 
> Signed-off-by: Amir Vadai <amir@vadai.me>
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>

Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
