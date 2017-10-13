From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/3] sched: act: ife: move encode/decode check to
 init
Date: Thu, 12 Oct 2017 21:38:20 -0400
Message-ID: <df414888-a723-f6df-f703-d83045ab25dd@mojatatu.com>
References: <20171011211608.22692-1-aring@mojatatu.com>
 <20171011211608.22692-2-aring@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, bjb@mojatatu.com,
        Yotam Gigi <yotamg@mellanox.com>
To: Alexander Aring <aring@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:48744 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753326AbdJMBiW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 21:38:22 -0400
Received: by mail-io0-f195.google.com with SMTP id j17so7434725iod.5
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 18:38:22 -0700 (PDT)
In-Reply-To: <20171011211608.22692-2-aring@mojatatu.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-10-11 05:16 PM, Alexander Aring wrote:
> This patch adds the check of the two possible ife handlings encode
> and decode to the init callback. The decode value is for usability
> aspect and used in userspace code only. The current code offers encode
> else decode only. This patch avoids any other option than this.
> 
> Signed-off-by: Alexander Aring <aring@mojatatu.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
