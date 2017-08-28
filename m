From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/3] if_ether: add forces ife lfb type
Date: Mon, 28 Aug 2017 18:03:44 -0400
Message-ID: <5256a495-4490-8e39-4ffc-83e928fe34e4@mojatatu.com>
References: <20170828190315.26646-1-aring@mojatatu.com>
 <20170828190315.26646-2-aring@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yotamg@mellanox.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        lucasb@mojatatu.com, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
To: Alexander Aring <aring@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33540 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750841AbdH1WDq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 18:03:46 -0400
Received: by mail-io0-f193.google.com with SMTP id s101so1612474ioe.0
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 15:03:46 -0700 (PDT)
In-Reply-To: <20170828190315.26646-2-aring@mojatatu.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-08-28 03:03 PM, Alexander Aring wrote:
> This patch adds the forces IFE lfb type according to IEEE registered
> ethertypes. See http://standards-oui.ieee.org/ethertype/eth.txt for more
> information. Since there exists the IFE subsystem it can be used there.
> 
> This patch also use the correct word "ForCES" instead of "FoRCES" which
> is a spelling error inside the IEEE ethertype specification.
> 
> Signed-off-by: Alexander Aring <aring@mojatatu.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
