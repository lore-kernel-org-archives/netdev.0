From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/10] korina cleanups/optimizations
Date: Sun, 15 Oct 2017 14:05:48 -0700 (PDT)
Message-ID: <20171015.140548.812014928035930297.davem@davemloft.net>
References: <20171015162226.606-1-roman@advem.lv>
        <0FA80CB3-C0DC-4B30-B638-26B5D46AE69E@gmail.com>
        <c3a2f516dcceb7dee9ea4dde634b58ed@advem.lv>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: roman@advem.lv
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48996 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750883AbdJOVFy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 17:05:54 -0400
In-Reply-To: <c3a2f516dcceb7dee9ea4dde634b58ed@advem.lv>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Yeryomin <roman@advem.lv>
Date: Sun, 15 Oct 2017 19:46:02 +0300

> On 2017-10-15 19:38, Florian Fainelli wrote:
>> On October 15, 2017 9:22:26 AM PDT, Roman Yeryomin <roman@advem.lv>
>> wrote:
>>> TX optimizations have led to ~15% performance increase (35->40Mbps)
>>> in local tx usecase (tested with iperf v3.2).
>> Could you avoid empty commit messages and write a paragraph or two for
>> each commit that explains what and why are you changing? The changes
>> look fine but they lack any explanation.
> 
> I thought that short descriptions are already self explanatory and
> just didn't know what to write more.

"Optimize TX handlers."

In what way?  Why?  How are things improved?  Is it measurable?
etc.
