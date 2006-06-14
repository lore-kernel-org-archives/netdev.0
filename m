From: Zach Brown <zach.brown@oracle.com>
Subject: Re: tcp_slow_start_after_idle
Date: Wed, 14 Jun 2006 10:09:52 -0700
Message-ID: <449042E0.4020409@oracle.com>
References: <20060613.223538.24611602.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:6557 "EHLO
	rgminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1750936AbWFNRKH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 13:10:07 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060613.223538.24611602.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Bringing back up this old topic:
> 
> 	http://marc.theaimsgroup.com/?l=linux-netdev&m=114564962420171&w=2
> 
> I've decided to add this tunable to the net-2.6.18 tree, patch below.

Nice, thanks for the heads-up.  I'll pass the notice on to the guys who
were asking about this in that thread.

- z
