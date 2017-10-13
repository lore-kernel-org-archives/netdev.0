From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 3/3] sched: act: ife: update parameters via rcu
 handling
Date: Thu, 12 Oct 2017 21:39:58 -0400
Message-ID: <b0112676-8281-12d6-72f8-0727211a13db@mojatatu.com>
References: <20171011211608.22692-1-aring@mojatatu.com>
 <20171011211608.22692-4-aring@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, bjb@mojatatu.com
To: Alexander Aring <aring@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:45437 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753327AbdJMBkA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 21:40:00 -0400
Received: by mail-it0-f68.google.com with SMTP id n195so9545130itg.0
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 18:40:00 -0700 (PDT)
In-Reply-To: <20171011211608.22692-4-aring@mojatatu.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-10-11 05:16 PM, Alexander Aring wrote:
> This patch changes the parameter updating via RCU and not protected by a
> spinlock anymore. This reduce the time that the spinlock is being held.
> 
> Signed-off-by: Alexander Aring <aring@mojatatu.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
