From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: mpls: Fix setting ttl_propagate for rt2
Date: Fri, 24 Mar 2017 14:11:38 -0700 (PDT)
Message-ID: <20170324.141138.874207018978092750.davem@davemloft.net>
References: <20170324010227.45375-1-dsa@cumulusnetworks.com>
        <20170324.132939.982617243186545861.davem@davemloft.net>
        <c6ad237b-8a83-32bb-0a1b-3599c8b0d66b@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rshearma@brocade.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44670 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752877AbdCXVMG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 17:12:06 -0400
In-Reply-To: <c6ad237b-8a83-32bb-0a1b-3599c8b0d66b@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Fri, 24 Mar 2017 14:32:42 -0600

> On 3/24/17 2:29 PM, David Miller wrote:
>> From: David Ahern <dsa@cumulusnetworks.com>
>> Date: Thu, 23 Mar 2017 19:02:27 -0600
>> 
>>> Fix copy and paste error setting rt_ttl_propagate.
>>>
>>> Fixes: 5b441ac8784c1 ("mpls: allow TTL propagation to IP packets to be configured")
>>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>> 
>> Applied.
>> 
> 
> Hi Dave: are you planning to merge net into net-next in the next few
> days? I have more MPLS patches for net-next but I know there are
> conflicts with changes in net. Wanted to get those patch sets out before
> netdev week.

I did a merge yesterday, so I am not likely to do another for about a week.
