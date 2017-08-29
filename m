From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] tc: act_ife: handle IEEE IFE ethertype as
 default
Date: Tue, 29 Aug 2017 15:14:35 -0700 (PDT)
Message-ID: <20170829.151435.94707661511628920.davem@davemloft.net>
References: <20170828190315.26646-1-aring@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, yotamg@mellanox.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, lucasb@mojatatu.com, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
To: aring@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40234 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751275AbdH2WOg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 18:14:36 -0400
In-Reply-To: <20170828190315.26646-1-aring@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <aring@mojatatu.com>
Date: Mon, 28 Aug 2017 15:03:12 -0400

> this patch series will introduce the IFE ethertype which is registered by
> IEEE. If the netlink act_ife type netlink attribute is not given it will
> use this value by default now.
> At least it will introduce some UAPI testcases to check if the default type
> is used if not specified and vice versa.

Series applied, thank you.
