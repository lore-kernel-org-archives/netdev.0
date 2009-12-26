From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add initrwnd to iproute2
Date: Sat, 26 Dec 2009 13:44:20 -0800 (PST)
Message-ID: <20091226.134420.245381671.davem@davemloft.net>
References: <pvm8wd3alec.fsf@chavey.mtv.corp.google.com>
	<20091226110855.6f43bcb4@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chavey@google.com, netdev@vger.kernel.org, therbert@google.com,
	eric.dumazet@gmail.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39596
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752299AbZLZVoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2009 16:44:19 -0500
In-Reply-To: <20091226110855.6f43bcb4@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sat, 26 Dec 2009 11:08:55 -0800

> On Tue, 15 Dec 2009 15:05:15 -0800
> chavey@google.com wrote:
> 
>> Add initrwnd option parsing to iproute. This option uses the new
>> rtnetlink init_rcvwnd to set the TCP initial receive window size
>> advertised by passive and active TCP connections.
> 
> Holding off iproute2 change until kernel change is accepted
> and merged

It is in net-next-2.6 already, so please add his patch to
your iproute2-next tree.
