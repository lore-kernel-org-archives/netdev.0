From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with
 IFLA_F_TEMPORARY flag
Date: Tue, 29 Oct 2013 15:58:09 -0400 (EDT)
Message-ID: <20131029.155809.311976718174740421.davem@davemloft.net>
References: <20131028.204306.2213130677400093266.davem@davemloft.net>
	<AE90C24D6B3A694183C094C60CF0A2F6026B73BB@saturn3.aculab.com>
	<20131029124010.GA15762@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, jiri@resnulli.us, vyasevich@gmail.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48157 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238Ab3J2T6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 15:58:12 -0400
In-Reply-To: <20131029124010.GA15762@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 29 Oct 2013 13:40:10 +0100

> It seems not that invasive to switch from af_packet to an udp socket
> with SO_BROADCAST set.

Precisely!
