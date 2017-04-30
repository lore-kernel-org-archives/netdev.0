From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/3] bnx2x: Replace custom scnprintf()
Date: Sun, 30 Apr 2017 11:32:18 -0400 (EDT)
Message-ID: <20170430.113218.1767277817865308181.davem@davemloft.net>
References: <20170427133701.72701-1-andriy.shevchenko@linux.intel.com>
        <BLUPR0701MB2004B5244F758FC95EE1B5E88D150@BLUPR0701MB2004.namprd07.prod.outlook.com>
        <CAHp75VcitfXWzUsUDthAXp97yjQQnEGND7eqSH-AFRVjH6pYDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@cavium.com, andriy.shevchenko@linux.intel.com,
        netdev@vger.kernel.org, Ariel.Elior@cavium.com
To: andy.shevchenko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49780 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968618AbdD3Pcm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 11:32:42 -0400
In-Reply-To: <CAHp75VcitfXWzUsUDthAXp97yjQQnEGND7eqSH-AFRVjH6pYDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Sun, 30 Apr 2017 15:58:18 +0300

> On Sun, Apr 30, 2017 at 11:16 AM, Mintz, Yuval <Yuval.Mintz@cavium.com> wrote:
>>> From: Andy Shevchenko <andy.shevchenko@gmail.com>
>>>
>>> Use scnprintf() when printing version instead of custom open coded variants.
>>>
>>> Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
>>
>> Hi Andy this seems correct.
>> Was there a cover-letter for your series? I've failed to find it.
> 
> There was none since patches are quite straight forward.

All patch series, regardless of how simple, should provide
a proper cover letter.

It is an essential part of all patch series.
