From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net: remove netif_set_real_num_rx_queues()
Date: Tue, 11 Nov 2014 09:07:29 -0800
Message-ID: <CAM_iQpVu63Ri4vsSfs_8NAH_ZmqtmGoPU8vjk-GLOJ6uQ5oBjQ@mail.gmail.com>
References: <1415648136-4167-1-git-send-email-xiyou.wangcong@gmail.com>
	<54620AC0.9080509@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:39282 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089AbaKKRHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 12:07:30 -0500
Received: by mail-ob0-f172.google.com with SMTP id wp4so7793858obc.3
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 09:07:29 -0800 (PST)
In-Reply-To: <54620AC0.9080509@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2014 at 5:10 AM, Edward Cree <ecree@solarflare.com> wrote:
>> -static inline int netif_copy_real_num_queues(struct net_device *to_dev,
>> -                                          const struct net_device *from_dev)
> Patch title says you're removing _set_ but body only removes _copy_.
> Which one is right?

Oops, my copy-n-paste error...
