From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Patch 3/5] Network Drop Monitor: Adding kfree_skb_clean for
 non-drops and modifying end-of-line points for skbs
Date: Thu, 05 Mar 2009 00:57:40 +0100
Message-ID: <49AF1574.9040902@trash.net>
References: <20090304161335.GC6392@ghostprotocols.net>	<20090304.130614.127792905.davem@davemloft.net>	<20090304224505.GD6392@ghostprotocols.net> <20090304.144722.167821808.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, nhorman@tuxdriver.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52504 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751794AbZCDX5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 18:57:46 -0500
In-Reply-To: <20090304.144722.167821808.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Arnaldo Carvalho de Melo <acme@redhat.com>
> Date: Wed, 4 Mar 2009 19:45:05 -0300
> 
>> hasta_la_vista_skbaby()
> 
> This is my personal favorite, it's very Mexifornia.

My clear favourite as well. Maybe for some procedure that leaks
the skb :)
