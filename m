From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 0/6] mISDN: Collection of patches for layer1/layer2
Date: Fri, 04 May 2012 12:02:24 -0400 (EDT)
Message-ID: <20120504.120224.2066297797928060408.davem@davemloft.net>
References: <1336140935-25830-1-git-send-email-kkeil@linux-pingi.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kkeil@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54756 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454Ab2EDQCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 12:02:30 -0400
In-Reply-To: <1336140935-25830-1-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <kkeil@linux-pingi.de>
Date: Fri,  4 May 2012 16:15:29 +0200

> Version 3
> 	Implement the TIMER3 configuration in one patch.
>         Fix additional issues found by checkpatch --strict
> 
> Version 2
> I removed the PCM only stuff and the 2MBit test mode and will rework
> them for a later submit. I added the lowlevel driver changes for the TIMER3
> config to this series.
> 
> These patches are mainly the outcome of a TBR3 recertification done
> within BT labs.
> The patches itself are very well tested more as 10000 valid/invalid
> call setup were done in preparartion for the TBR3 aproval.
> 
> For net-next.

All applied, thanks.
