From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 0/6] Add Geneve tunnel protocol support
Date: Mon, 06 Oct 2014 00:32:50 -0400 (EDT)
Message-ID: <20141006.003250.2261438479584184724.davem@davemloft.net>
References: <1412375733-30981-1-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: azhou@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57683 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbaJFEcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 00:32:52 -0400
In-Reply-To: <1412375733-30981-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>
Date: Fri,  3 Oct 2014 15:35:27 -0700

> This patch series adds kernel support for Geneve (Generic Network
> Virtualization Encapsulation) based on Geneve IETF draft:
> http://www.ietf.org/id/draft-gross-geneve-01.txt
> 
> Patch 1 implements Geneve tunneling protocol driver
> 
> Patch 2-6 adds openvswitch support for creating and using
> Geneve tunnels by OVS user space.
> 
> ---
> v1->v2:   Style fixes: use tab instead space for Kconfig
> 	  Patch 2-6 are reviewed by Pravin Shetty, add him to acked-by
> 	  Patch 6 was reviewed by Thomas Graf when commiting
> 	    to openvswitch.org, add him to acked-by.

Series applied, thanks Andy.
