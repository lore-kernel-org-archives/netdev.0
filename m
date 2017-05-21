From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] net: ipv6: fix code style error and
 warning of ndisc.c
Date: Sun, 21 May 2017 12:54:04 -0400 (EDT)
Message-ID: <20170521.125404.420857788471820007.davem@davemloft.net>
References: <1495328154-18653-1-git-send-email-cugyly@163.com>
        <1495382708.2093.10.camel@perches.com>
        <77510dfe-4fc7-4446-9f1a-aea52342ecd1@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, cugyly@163.com, netdev@vger.kernel.org,
        Linyu.Yuan@alcatel-sbell.com.cn
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44824 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdEUQyM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 12:54:12 -0400
In-Reply-To: <77510dfe-4fc7-4446-9f1a-aea52342ecd1@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Sun, 21 May 2017 10:17:47 -0600

> On 5/21/17 10:05 AM, Joe Perches wrote:
>> But really, why bother?
>> 
>> Just because checkpatch bleats some message doesn't
>> mean it _has_ to be fixed.
>> 
>> Please strive to make the code more readable and
>> intelligible for _humans_.  Compilers don't care.
> 
> +1
> 
> broad cleanups like this make 'git blame' harder to use to find root causes.

I agree, and I'm pretty much going to ignore these ndisc.c cleanup
changes.

Sorry.
