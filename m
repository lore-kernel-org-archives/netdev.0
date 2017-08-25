From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next v2 2/4] net_sched: introduce tclass_del_notify()
Date: Fri, 25 Aug 2017 07:51:41 -0400
Message-ID: <f41065d6-1a26-1c1f-d5d7-61161b098ec0@mojatatu.com>
References: <20170824235130.28503-1-xiyou.wangcong@gmail.com>
 <20170824235130.28503-3-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:37476 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756227AbdHYLvo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 07:51:44 -0400
Received: by mail-it0-f42.google.com with SMTP id 77so562846itj.0
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 04:51:44 -0700 (PDT)
In-Reply-To: <20170824235130.28503-3-xiyou.wangcong@gmail.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-08-24 07:51 PM, Cong Wang wrote:
> Like for TC actions, ->delete() is a special case,
> we have to prepare and fill the notification before delete
> otherwise would get use-after-free after we remove the
> reference count.
> 
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
