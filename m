From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: mpls: Fix setting ttl_propagate for rt2
Date: Fri, 24 Mar 2017 14:32:42 -0600
Message-ID: <c6ad237b-8a83-32bb-0a1b-3599c8b0d66b@cumulusnetworks.com>
References: <20170324010227.45375-1-dsa@cumulusnetworks.com>
 <20170324.132939.982617243186545861.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rshearma@brocade.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34559 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965355AbdCXUly (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 16:41:54 -0400
Received: by mail-pf0-f173.google.com with SMTP id p189so576800pfp.1
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 13:41:53 -0700 (PDT)
In-Reply-To: <20170324.132939.982617243186545861.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/24/17 2:29 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Thu, 23 Mar 2017 19:02:27 -0600
> 
>> Fix copy and paste error setting rt_ttl_propagate.
>>
>> Fixes: 5b441ac8784c1 ("mpls: allow TTL propagation to IP packets to be configured")
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> 
> Applied.
> 

Hi Dave: are you planning to merge net into net-next in the next few
days? I have more MPLS patches for net-next but I know there are
conflicts with changes in net. Wanted to get those patch sets out before
netdev week.

Thanks
