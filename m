From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: arp_notify address list bug
Date: Wed, 07 Oct 2009 03:18:25 -0700 (PDT)
Message-ID: <20091007.031825.236018689.davem@davemloft.net>
References: <4ACAB5BC.1020307@gmail.com>
	<20091005.213103.237708475.davem@davemloft.net>
	<4ACAD393.5080909@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53533
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758110AbZJGKSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 06:18:30 -0400
In-Reply-To: <4ACAD393.5080909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 06 Oct 2009 07:20:19 +0200

> From: Stephen Hemminger <shemminger@vyatta.com>
> 
> This fixes a bug with arp_notify.
> 
> If arp_notify is enabled, kernel will crash if address is changed
> and no IP address is assigned.
>   http://bugzilla.kernel.org/show_bug.cgi?id=14330
> 
> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
