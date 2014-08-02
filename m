From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ipv6: data of fwmark_reflect sysctl needs to be
 updated on netns construction
Date: Sat, 02 Aug 2014 16:17:53 -0700 (PDT)
Message-ID: <20140802.161753.287652834100823770.davem@davemloft.net>
References: <8775e97335210450f3ed5a16e64e4d03df026713.1406896673.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49954 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733AbaHBXRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2014 19:17:55 -0400
In-Reply-To: <8775e97335210450f3ed5a16e64e4d03df026713.1406896673.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri,  1 Aug 2014 14:41:10 +0200

> Fixes: e110861f86094cd ("net: add a sysctl to reflect the fwmark on replies")
> Cc: Lorenzo Colitti <lorenzo@google.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> 
> Sorry, missed the correct patch on the earlier submission. This knob
> needs to be renumbered to '4' when merged with net-next.

Ok applied, thanks Hannes.
