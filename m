From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] be2net fixes
Date: Thu, 02 May 2013 16:46:26 -0400 (EDT)
Message-ID: <20130502.164626.1519508217069165984.davem@davemloft.net>
References: <d4e5f897-f081-4b3d-aad0-6ea296cae6db@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32774 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761255Ab3EBUq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 16:46:29 -0400
In-Reply-To: <d4e5f897-f081-4b3d-aad0-6ea296cae6db@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Thu, 2 May 2013 19:06:14 +0530

> Pls apply
> 
> Kalesh AP (2):
>   be2net: Fix firmware download for Lancer
>   be2net: avoid napi_disable() when it has not been enabled
> 
> Somnath Kotur (1):
>   be2net: Fix to fail probe if MSI-X enable fails for a VF

Can you be2net knuckleheads possibly coordinate?

Please?

There was already a series submitted by Ajit and your work overlaps
and conflicts with his patch set applied.

I sorted out the merge problems and was able to apply your series too,
but you guys cannot have two patch sets for the same driver in flight
at the same time.
