From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH iproute2 1/4] tc: m_ife: allow ife type to zero
Date: Mon, 28 Aug 2017 18:16:55 -0400
Message-ID: <5523e732-07f5-ac4b-8c88-6914c0e32ff0@mojatatu.com>
References: <20170828190738.26829-1-aring@mojatatu.com>
 <20170828190738.26829-2-aring@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yotamg@mellanox.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        netdev@vger.kernel.org
To: Alexander Aring <aring@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:32840 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751190AbdH1WQ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 18:16:57 -0400
Received: by mail-io0-f196.google.com with SMTP id s101so1641977ioe.0
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 15:16:57 -0700 (PDT)
In-Reply-To: <20170828190738.26829-2-aring@mojatatu.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-08-28 03:07 PM, Alexander Aring wrote:
> This patch allows to set an ethertype for IFE which is zero. There is no
> kernel side validation which forbids a type to zero.
> 
> Signed-off-by: Alexander Aring <aring@mojatatu.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
