From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Revert "ipv4: make net_protocol const"
Date: Mon, 28 Aug 2017 14:30:57 -0700 (PDT)
Message-ID: <20170828.143057.1225113814212085629.davem@davemloft.net>
References: <1503951789-31836-1-git-send-email-dsahern@gmail.com>
        <20170828.140133.2126200702424568912.davem@davemloft.net>
        <80c558d4-dea8-3a60-3786-c70e55946ff2@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhumirks@gmail.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48712 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751182AbdH1Va6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 17:30:58 -0400
In-Reply-To: <80c558d4-dea8-3a60-3786-c70e55946ff2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Mon, 28 Aug 2017 15:03:34 -0600

> On 8/28/17 3:01 PM, David Miller wrote:
>> From: David Ahern <dsahern@gmail.com>
>> Date: Mon, 28 Aug 2017 13:23:09 -0700
>> 
>>> This reverts commit aa8db499ea67cff1f5f049033810ffede2fe5ae4.
>> ...
>>> I think this is the second time such a patch has been reverted.
>> 
>> Then please add a comment, it will help prevent this from happening
>> again.
>> 
> 
> Was going to do that in both places after the revert. You want it as
> part of this one?

You're right a clean revert first is better.

I'll apply this now, thanks David.
