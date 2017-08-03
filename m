From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Introduce ipip_offload_init helper function.
Date: Thu, 03 Aug 2017 09:27:21 -0700 (PDT)
Message-ID: <20170803.092721.2255655703483726186.davem@davemloft.net>
References: <1501691655-3493-1-git-send-email-xiangxia.m.yue@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiangxia.m.yue@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45114 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751158AbdHCQ1V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 12:27:21 -0400
In-Reply-To: <1501691655-3493-1-git-send-email-xiangxia.m.yue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Date: Wed,  2 Aug 2017 09:34:15 -0700

> It's convenient to init ipip offload. We will check
> the return value, and print KERN_CRIT info on failure.
> 
> Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>

Applied.
