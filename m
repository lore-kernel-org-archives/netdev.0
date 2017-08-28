From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 3/3] tc-testing: add test for testing ife type
Date: Mon, 28 Aug 2017 18:16:21 -0400
Message-ID: <2a2dccf2-9a3d-8ce3-32ab-db0e20ee752c@mojatatu.com>
References: <20170828190315.26646-1-aring@mojatatu.com>
 <20170828190315.26646-4-aring@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yotamg@mellanox.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        lucasb@mojatatu.com, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
To: Alexander Aring <aring@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35432 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751190AbdH1WQX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 18:16:23 -0400
Received: by mail-io0-f193.google.com with SMTP id c18so1636226ioj.2
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 15:16:23 -0700 (PDT)
In-Reply-To: <20170828190315.26646-4-aring@mojatatu.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-08-28 03:03 PM, Alexander Aring wrote:
> This patch adds a new testcase for the IFE type setting in tc. In case
> of user specified the type it will check if the ife is correctly
> configured to react on it. If it's not specified the default IFE type
> should be used.
> 
> Signed-off-by: Alexander Aring <aring@mojatatu.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>


We should add the tests which do filter binding as well
(both auto-binding and late binding)

cheers,
jamal
