From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: remove netif_set_real_num_rx_queues()
Date: Tue, 11 Nov 2014 15:22:30 -0500 (EST)
Message-ID: <20141111.152230.450027764385147439.davem@davemloft.net>
References: <1415648136-4167-1-git-send-email-xiyou.wangcong@gmail.com>
	<54620AC0.9080509@solarflare.com>
	<CAM_iQpVu63Ri4vsSfs_8NAH_ZmqtmGoPU8vjk-GLOJ6uQ5oBjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ecree@solarflare.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33106 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944AbaKKUWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 15:22:32 -0500
In-Reply-To: <CAM_iQpVu63Ri4vsSfs_8NAH_ZmqtmGoPU8vjk-GLOJ6uQ5oBjQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 11 Nov 2014 09:07:29 -0800

> On Tue, Nov 11, 2014 at 5:10 AM, Edward Cree <ecree@solarflare.com> wrote:
>>> -static inline int netif_copy_real_num_queues(struct net_device *to_dev,
>>> -                                          const struct net_device *from_dev)
>> Patch title says you're removing _set_ but body only removes _copy_.
>> Which one is right?
> 
> Oops, my copy-n-paste error...

Please resubmit with fixed title, thanks.
