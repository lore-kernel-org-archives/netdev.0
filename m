From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 2/2] qlcnic: diag fixes
Date: Sat, 24 Jul 2010 20:42:38 -0700 (PDT)
Message-ID: <20100724.204238.104050285.davem@davemloft.net>
References: <1279956266-23445-1-git-send-email-amit.salecha@qlogic.com>
	<1279956266-23445-3-git-send-email-amit.salecha@qlogic.com>
	<20100724165343.GC9787@vigoh>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amit.salecha@qlogic.com, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com
To: gustavo@padovan.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40622
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751162Ab0GYDmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jul 2010 23:42:21 -0400
In-Reply-To: <20100724165343.GC9787@vigoh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Gustavo F. Padovan" <gustavo@padovan.org>
Date: Sat, 24 Jul 2010 13:53:43 -0300

> Hi Amit,
> 
> * amit.salecha@qlogic.com <amit.salecha@qlogic.com> [2010-07-24 00:24:26 -0700]:
> 
>> From: Amit Kumar Salecha <amit.salecha@qlogic.com>
>> 
>> o Loopback not supported for virtual function.
>> o netif_device_attach was missing in error path from
>>   qlcnic_diag_alloc_res
> 
> This second part should be a new commit actually. It fixes a different
> thing.

Agreed.
