From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bpf: testing: fix devmap tests
Date: Sat, 29 Jul 2017 14:13:50 -0700 (PDT)
Message-ID: <20170729.141350.234393708636508572.davem@davemloft.net>
References: <20170727003206.16649.50637.stgit@john-Precision-Tower-5810>
        <5979355D.60807@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        daniel@iogearbox.net
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41980 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751612AbdG2VNv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 17:13:51 -0400
In-Reply-To: <5979355D.60807@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Wed, 26 Jul 2017 17:35:41 -0700

> On 07/26/2017 05:32 PM, John Fastabend wrote:
>> Apparently through one of my revisions of the initial patches
>> series I lost the devmap test. We can add more testing later but
>> for now lets fix the simple one we have.
>> 
>> Fixes: 546ac1ffb70d "bpf: add devmap, a map for storing net device references"
>> Reported-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>> Signed-off-by: John Fastabend <john.fastabend@gmail.com>
>> ---
> 
> Forgot prefix, this is for net-next. Sorry about that.

It's ok.

Aplpied, thanks John.
