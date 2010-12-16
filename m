From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: fix the return value of getting the sctp partial
 delivery point
Date: Thu, 16 Dec 2010 14:49:36 -0800 (PST)
Message-ID: <20101216.144936.68120774.davem@davemloft.net>
References: <4D0823A1.6080307@cn.fujitsu.com>
	<4D08E46A.5010703@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yjwei@cn.fujitsu.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54681
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752109Ab0LPWtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 17:49:07 -0500
In-Reply-To: <4D08E46A.5010703@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 15 Dec 2010 10:53:14 -0500

> On 12/14/2010 09:10 PM, Wei Yongjun wrote:
>> Get the sctp partial delivery point using SCTP_PARTIAL_DELIVERY_POINT
>> socket option should return 0 if success, not -ENOTSUPP.
>> 
> 
> Ack.
> 
> -vlad
> 
>> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied, thanks everyone.

Vlad, please use properly formed full "Acked-by: ..." in the
future otherwise automated tools don't pick it up and it's
therefore more likely your ACK gets lost.

Thanks :-)
