From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH] netfilter: ipset: ip_set_bitmap_ipmac: use swap macro
 in bitmap_ipmac_create
Date: Mon, 30 Oct 2017 16:55:16 -0500
Message-ID: <20171030165516.Horde.8Op0mu-plHOeski7kja-KgD@gator4166.hostgator.com>
References: <20171028201743.GA32474@embeddedor.com>
 <alpine.DEB.2.11.1710300840160.8496@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway22.websitewelcome.com ([192.185.46.224]:30155 "EHLO
        gateway22.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752133AbdJ3VzS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 17:55:18 -0400
Received: from cm17.websitewelcome.com (cm17.websitewelcome.com [100.42.49.20])
        by gateway22.websitewelcome.com (Postfix) with ESMTP id 79EF74B09
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 16:55:17 -0500 (CDT)
In-Reply-To: <alpine.DEB.2.11.1710300840160.8496@blackhole.kfki.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jozsef,

Quoting Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>:

> Hi,
>
> On Sat, 28 Oct 2017, Gustavo A. R. Silva wrote:
>
>> Make use of the swap macro and remove unnecessary variable tmp.
>> This makes the code easier to read and maintain.
>>
>> This code was detected with the help of Coccinelle.
>>
>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>
> Please resubmit the tree patches as a single one, they do the same thing.
> Thanks!
>

OK. I'll do that.

Thanks
