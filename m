From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V4 0/3] net: bulk free adjustment and two
 driver use-cases
Date: Sun, 13 Mar 2016 22:35:53 -0400 (EDT)
Message-ID: <20160313.223553.1984627891818115069.davem@davemloft.net>
References: <20160311084549.1b011723@redhat.com>
	<20160311084245.5207.70640.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	eugenia@mellanox.com, alexander.duyck@gmail.com,
	alexei.starovoitov@gmail.com, saeedm@mellanox.com,
	gerlitz.or@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40613 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753266AbcCNCf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 22:35:57 -0400
In-Reply-To: <20160311084245.5207.70640.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 11 Mar 2016 09:43:48 +0100

> I've split out the bulk free adjustments, from the bulk alloc patches,
> as I want the adjustment to napi_consume_skb be in same kernel cycle
> the API was introduced.
> 
> Adjustments based on discussion:
>  Subj: "mlx4: use napi_consume_skb API to get bulk free operations"
>  http://thread.gmane.org/gmane.linux.network/402503/focus=403386
> 
> Patchset based on net-next at commit 3ebeac1d0295
> 
> V4: more nitpicks from Sergei
> V3: spelling fixes from Sergei

Series applied, thanks Jesper.
