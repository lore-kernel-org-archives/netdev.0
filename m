From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 1/9] bonding: lockdep annotation
Date: Sun, 12 Nov 2006 11:40:02 -0500
Message-ID: <45574E62.8010007@garzik.org>
References: <200611090351.kA93p1Kx003677@shell0.pdx.osdl.net>	<4554A435.5070500@garzik.org> <20061110.124556.130237858.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, a.p.zijlstra@chello.nl,
	mingo@elte.hu, shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:27088 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1753734AbWKLQkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Nov 2006 11:40:07 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061110.124556.130237858.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Fri, 10 Nov 2006 11:09:25 -0500
> 
>> akpm@osdl.org wrote:
>>> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
>>>
>>> =============================================
>>> [ INFO: possible recursive locking detected ]
>>> 2.6.17-1.2600.fc6 #1
>>> ---------------------------------------------
>> applied; please CC me on this drivers/net stuff
> 
> Jeff, I put this one in my net-2.6.20 tree already.

Well, it was drivers/net/bonding/* which usually goes in through my 
tree, what did you expect?  :)

	Jeff



