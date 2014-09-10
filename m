From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: Convert the normal transmit complete
 path to dev_consume_skb_any()
Date: Tue, 09 Sep 2014 17:34:13 -0700 (PDT)
Message-ID: <20140909.173413.874210494200550766.davem@davemloft.net>
References: <1410304704.7106.22.camel@edumazet-glaptop2.roam.corp.google.com>
	<540F8F78.9020502@hp.com>
	<1410308730.7106.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, raj@tardy.usa.hp.com, netdev@vger.kernel.org,
	sshah@solarflare.com, linux-net-drivers@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34315 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbaIJAeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 20:34:14 -0400
In-Reply-To: <1410308730.7106.23.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 09 Sep 2014 17:25:30 -0700

> On Tue, 2014-09-09 at 16:38 -0700, Rick Jones wrote:
> 
>> I can remove that const, and then smooth the ripples stemming from it to 
>> arrive at something like:
> 
> Oh I missed this const, so this will be a different patch, sorry for
> this.
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.

 
