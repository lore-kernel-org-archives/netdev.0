From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 2/3] act_ife: use registered ife_type as fallback
Date: Mon, 28 Aug 2017 18:14:08 -0400
Message-ID: <6b689b5a-c752-748d-8b3f-b369b9d49bea@mojatatu.com>
References: <20170828190315.26646-1-aring@mojatatu.com>
 <20170828190315.26646-3-aring@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yotamg@mellanox.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        lucasb@mojatatu.com, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
To: Alexander Aring <aring@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:37803 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751218AbdH1WOK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 18:14:10 -0400
Received: by mail-io0-f193.google.com with SMTP id j99so1624616ioo.4
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 15:14:10 -0700 (PDT)
In-Reply-To: <20170828190315.26646-3-aring@mojatatu.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-08-28 03:03 PM, Alexander Aring wrote:
> This patch handles a default IFE type if it's not given by user space
> netlink api. The default IFE type will be the registered ethertype by
> IEEE for IFE ForCES.
> 
> Signed-off-by: Alexander Aring <aring@mojatatu.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
