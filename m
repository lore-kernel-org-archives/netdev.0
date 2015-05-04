From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next #3 0/8] via-rhine rework
Date: Mon, 04 May 2015 00:18:55 -0400 (EDT)
Message-ID: <20150504.001855.6237714217174023.davem@davemloft.net>
References: <cover.1430509434.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nix@esperi.org.uk,
	Roger.Luethi.rl@hellgate.ch, gurligebis@gentoo.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59613 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798AbbEDES5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 00:18:57 -0400
In-Reply-To: <cover.1430509434.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri,  1 May 2015 22:14:37 +0200

> The series applies against davem-next as of
> 9dd3c797496affd699805c8a9d8429ad318c892f ("drivers: net: xgene: fix kbuild
> warnings").
> 
> Patches #1..#4 avoid holes in the receive ring.
> 
> Patch #5 is a small leftover cleanup for #1..#4.
> 
> Patches #6 and #7 are fairly simple barrier stuff.
> 
> Patch #8 closes some SMP transmit races - not that anyone really
> complained about these but it's a bit hard to handwave that they
> can be safely ignored. Some testing, especially SMP testing of
> course, would be welcome.

Looks great, series applied, thanks a lot!
