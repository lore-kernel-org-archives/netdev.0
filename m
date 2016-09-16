From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 0/5] mlx4 misc fixes and improvements
Date: Fri, 16 Sep 2016 10:46:29 +0300
Message-ID: <CAJ3xEMjo3Ed+ULdUD24FOBJD5g_vPMd6H2tR1UNqO0ex1p2E3Q@mail.gmail.com>
References: <1473686416-11779-1-git-send-email-tariqt@mellanox.com> <20160915.192106.739428651744920778.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tariq Toukan <tariqt@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34422 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756329AbcIPHqb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 03:46:31 -0400
Received: by mail-oi0-f65.google.com with SMTP id v62so2404179oig.1
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 00:46:30 -0700 (PDT)
In-Reply-To: <20160915.192106.739428651744920778.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 16, 2016 at 2:21 AM, David Miller <davem@davemloft.net> wrote:
> From: Tariq Toukan <tariqt@mellanox.com>
> Date: Mon, 12 Sep 2016 16:20:11 +0300
>
>> This patchset contains some bug fixes, a cleanup, and small improvements
>> from the team to the mlx4 Eth and core drivers.
>>
>> Series generated against net-next commit:
>> 02154927c115 "net: dsa: bcm_sf2: Get VLAN_PORT_MASK from b53_device"
>>
>> Please push the following patch to -stable  >= 4.6 as well:
>> "net/mlx4_core: Fix to clean devlink resources"
>
> Again, coding style fixes and optimizations like branch prediction
> hints are not bug fixes and therefore not appropriate for 'net'.

Hi Dave,

He sent it to net-next, not net... ok?

Or.
