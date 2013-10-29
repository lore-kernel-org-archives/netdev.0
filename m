From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] bnx2x: Bug fixes patch series
Date: Tue, 29 Oct 2013 00:13:15 -0400 (EDT)
Message-ID: <20131029.001315.1613976020813375813.davem@davemloft.net>
References: <1382872008-1073-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dmitry@broadcom.com, ariele@broadcom.com,
	eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40361 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719Ab3J2ENR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 00:13:17 -0400
In-Reply-To: <1382872008-1073-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Sun, 27 Oct 2013 13:06:47 +0200

> This series contains 2 unrelated fixes:
> 
>  1. FW asserts during unload might be encountered if specific memory
>     allocations fail during load.
> 
>  2. SR-IOV related, fixes a crash that will occour if the driver were to
>     be rmmoded and then re-probed while there are both assigned and unassigned
>     VFs originating from the same PF.
> 
> Please consider applying these patches to `net'.

Both applied, thanks.
