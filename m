From: Sagi Grimberg <sagi@grimberg.me>
Subject: Re: [PATCH v3 0/4] Introduce a new helper for parsing ipv[4|6]:port
 to socket address
Date: Wed, 29 Mar 2017 20:22:12 +0300
Message-ID: <9251950f-9e97-6768-6362-39e3a7a77d39@grimberg.me>
References: <55ad78fd-266f-09b9-417d-b6cf7b723879@grimberg.me>
 <17d44419-a9db-1822-985e-619083e999b9@grimberg.me>
 <a484e88e-317c-42a6-f7c2-69b77cb8486a@grimberg.me>
 <20170329.101617.2078695643478702071.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-nvme@lists.infradead.org, netdev@vger.kernel.org, hch@lst.de,
        axboe@fb.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35835 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752794AbdC2RWQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 13:22:16 -0400
Received: by mail-wr0-f195.google.com with SMTP id p52so4883534wrc.2
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 10:22:15 -0700 (PDT)
In-Reply-To: <20170329.101617.2078695643478702071.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Dave, thanks for replying.

> Please repost, the problem was you mixed it in a series that was
> not targetting the net tree, so it was confusing what was going on.

I see, I posted the entire series because adding a helper without
seeing it's call sites might be too detached.

> Just submit the networking change, by itself, for review.

I will.
