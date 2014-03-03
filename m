From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/4] be2net fixes
Date: Mon, 03 Mar 2014 15:48:36 -0500 (EST)
Message-ID: <20140303.154836.1238922177486347244.davem@davemloft.net>
References: <07564252-a4d2-43fa-b3b1-41df316f706d@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54953 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755151AbaCCUsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 15:48:38 -0500
In-Reply-To: <07564252-a4d2-43fa-b3b1-41df316f706d@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Mon, 3 Mar 2014 14:24:05 +0530

> Please apply.
> 
> Somnath Kotur (1):
>   be2net: Fix to reset transparent vlan tagging
> 
> Somnath kotur (1):
>   be2net: clear promiscuous bits in adapter->flags while disabling
>     promiscuous mode
> 
> Vasundhara Volam (2):
>   be2net: Fix skb double free in be_xmit_wrokarounds() failure path
>   be2net: isolate TX workarounds not applicable to Skyhawk-R

Series applied, thank you.
