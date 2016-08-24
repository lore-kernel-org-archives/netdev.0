From: Ying Xue <ying.xue0@gmail.com>
Subject: Re: [PATCH -next] tipc: use kfree_skb() instead of kfree()
Date: Wed, 24 Aug 2016 18:18:47 +0800
Message-ID: <e2471868-3aee-9549-bda0-33559da2519f@gmail.com>
References: <1471993262-4061-1-git-send-email-weiyj.lk@gmail.com>
 <25A14D9CFAB7B34FB9440F90AFD35233010193E3DF@ALA-MBA.corp.ad.wrs.com>
 <20160823.230035.1705446489596549151.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: weiyj.lk@gmail.com, jon.maloy@ericsson.com, weiyongjun1@huawei.com,
        netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33519 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752902AbcHXKez (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 06:34:55 -0400
Received: by mail-pa0-f66.google.com with SMTP id vy10so964589pac.0
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 03:34:55 -0700 (PDT)
In-Reply-To: <20160823.230035.1705446489596549151.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2016 02:00 PM, David Miller wrote:
> From: "Xue, Ying" <Ying.Xue@windriver.com>
> Date: Wed, 24 Aug 2016 02:47:32 +0000
> 
>> Acked-by: Ying Xue <ying.xue@windriver.com>
> 
> Please do not ACK patches like this.
> 
> If you quote the patch with no demarcation in the initial column for
> the quoted text, like so:
> 
>> From: Wei Yongjun [mailto:weiyj.lk@gmail.com] 
>> Sent: Wednesday, August 24, 2016 7:01 AM
>> To: Jon Maloy; Xue, Ying; David S. Miller
>> Cc: Wei Yongjun; netdev@vger.kernel.org; tipc-discussion@lists.sourceforge.net
>> Subject: [PATCH -next] tipc: use kfree_skb() instead of kfree()
>>
>> From: Wei Yongjun <weiyongjun1@huawei.com>
>>
>> Use kfree_skb() instead of kfree() to free sk_buff.
>  ...
> 
> then it makes it look like _you_ are posting this patch, so it ends up
> again in patchwork and your ACK gets lost.
> 
> I truly feel like I've told you this at least one time already before,
> so please fix your quoting so that it adheres to the list posting
> standards used by everyone else here.
> 

Sorry for bringing such inconvenience for you.
I am sure I will strictly follow the standards in the future.

Regards,
Ying

> Thank you.
> 
