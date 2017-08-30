From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] SRIOV VF VGT+ and violation counters
 support
Date: Wed, 30 Aug 2017 11:39:06 -0700 (PDT)
Message-ID: <20170830.113906.1260728580783503343.davem@davemloft.net>
References: <20170827110618.20599-1-saeedm@mellanox.com>
        <CALzJLG9FDh9XJKOGBxqxLqrJf3FSFxX8dZRLALxJRA7G-NQBBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, netdev@vger.kernel.org, eugenia@mellanox.com
To: saeedm@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58978 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751507AbdH3SjH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 14:39:07 -0400
In-Reply-To: <CALzJLG9FDh9XJKOGBxqxLqrJf3FSFxX8dZRLALxJRA7G-NQBBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Date: Wed, 30 Aug 2017 21:33:18 +0300

> On Sun, Aug 27, 2017 at 2:06 PM, Saeed Mahameed <saeedm@mellanox.com> wrote:
>> Hi Dave
>>
>> This series provides two security SRIOV related features (VGT+ and VF violation counters).
>>
>> VGT+ is a security feature that gives the administrator the ability of controlling
>> the allowed VGT vlan IDs list that can be transmitted/received from/to the VF.
>> The allowed VGT vlan IDs list is called "trunk".
>>
> 
> Dave, I would like to drop this series for now since we need to respin
> and find a better API to query vlan lists. it seems that it will take
> some time for our developer to complete this. So i would like to
> submit something else in the meanwhile.

If you look in patchwork I marked these patches as "Changes requested" so there
is nothing you need to worry about.
