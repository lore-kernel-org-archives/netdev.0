From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/4] Introduce a new helper for parsing
 ipv[4|6]:port to socket address
Date: Wed, 29 Mar 2017 10:16:17 -0700 (PDT)
Message-ID: <20170329.101617.2078695643478702071.davem@davemloft.net>
References: <55ad78fd-266f-09b9-417d-b6cf7b723879@grimberg.me>
        <17d44419-a9db-1822-985e-619083e999b9@grimberg.me>
        <a484e88e-317c-42a6-f7c2-69b77cb8486a@grimberg.me>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-nvme@lists.infradead.org, netdev@vger.kernel.org, hch@lst.de,
        axboe@fb.com
To: sagi@grimberg.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49024 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752872AbdC2RQW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 13:16:22 -0400
In-Reply-To: <a484e88e-317c-42a6-f7c2-69b77cb8486a@grimberg.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sagi Grimberg <sagi@grimberg.me>
Date: Wed, 29 Mar 2017 19:50:51 +0300

> 
>>> Hi Dave,
>>>
>>> This set got review tags from two kernel maintainers but this is your
>>> realm so I wouldn't be comfortable moving forward with this without
>>> your feedback.
>>
>> Would it be possible to get a review from one of the netdev folks
>> on patch 1/4?
> 
> Hi everyone,
> 
> Still no feedback...
> 
> This patchset is targeted to 4.12 as it adds IPv6 support to
> nvme over fabrics drivers which is desired by some linux users.

Please repost, the problem was you mixed it in a series that was
not targetting the net tree, so it was confusing what was going on.

Just submit the networking change, by itself, for review.

Thank you.
