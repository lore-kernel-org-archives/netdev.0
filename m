From: Sagi Grimberg <sagi@grimberg.me>
Subject: Re: [PATCH v3 0/4] Introduce a new helper for parsing ipv[4|6]:port
 to socket address
Date: Wed, 29 Mar 2017 19:50:51 +0300
Message-ID: <a484e88e-317c-42a6-f7c2-69b77cb8486a@grimberg.me>
References: <1489063793-12838-1-git-send-email-sagi@grimberg.me>
 <55ad78fd-266f-09b9-417d-b6cf7b723879@grimberg.me>
 <17d44419-a9db-1822-985e-619083e999b9@grimberg.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-nvme@lists.infradead.org, netdev@vger.kernel.org,
        Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@fb.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36532 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751216AbdC2Quz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 12:50:55 -0400
Received: by mail-wr0-f194.google.com with SMTP id k6so3366399wre.3
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 09:50:54 -0700 (PDT)
In-Reply-To: <17d44419-a9db-1822-985e-619083e999b9@grimberg.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> Hi Dave,
>>
>> This set got review tags from two kernel maintainers but this is your
>> realm so I wouldn't be comfortable moving forward with this without
>> your feedback.
>
> Would it be possible to get a review from one of the netdev folks
> on patch 1/4?

Hi everyone,

Still no feedback...

This patchset is targeted to 4.12 as it adds IPv6 support to
nvme over fabrics drivers which is desired by some linux users.

Given that I'm in v3 by now, and accumulated reviews from two kernel
maintainers, Unless someone is strongly against it, I'll be queuing this 
from the nvme tree to 4.12.

Cheers,
Sagi.
