From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH] atm: solos-pci: remove useless variable assignments
Date: Thu, 15 Jun 2017 16:43:36 -0500
Message-ID: <20170615164336.Horde.41f0yf4qsGt84ZI8i8R-i9B@gator4166.hostgator.com>
References: <20170615195621.GA5600@embeddedgus>
 <20170615.173334.947301773714825384.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway34.websitewelcome.com ([192.185.149.222]:35536 "EHLO
        gateway34.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752548AbdFOVnu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 17:43:50 -0400
Received: from cm11.websitewelcome.com (cm11.websitewelcome.com [100.42.49.5])
        by gateway34.websitewelcome.com (Postfix) with ESMTP id 6191F83E649
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 16:43:37 -0500 (CDT)
In-Reply-To: <20170615.173334.947301773714825384.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Quoting David Miller <davem@davemloft.net>:

> From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
> Date: Thu, 15 Jun 2017 14:56:21 -0500
>
>> Value assigned to variable _data32_ at lines 1254 and 1257 is
>> overwritten at line 1260 before it can be used. This makes
>> such variable assignments useless.
>>
>> Addresses-Coverity-ID: 1227049
>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>
> Applied, thanks.

Absolutely, glad to help.

Regards
