From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 00/12] bnx2x series
Date: Sun, 13 Nov 2011 16:06:13 -0500 (EST)
Message-ID: <20111113.160613.382531598058533705.davem@davemloft.net>
References: <1321194872-8276-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690Ab1KMVGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2011 16:06:16 -0500
In-Reply-To: <1321194872-8276-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Sun, 13 Nov 2011 16:34:20 +0200

> Changes from v2:
>     - Patch: "bnx2x: simplify definition of RX_SGE_MASK_LEN and use it"
>       fixed according to Joe Perches <joe@perches.com> comment.
>   
> Changes from v1:
>     - Removed patch with pri_map module parameter.  
> 
> 
> Hello Dave,
> 
> The series includes re-enabling FCoE and DCB for 578xx devices,
> some improvements in licensing for cnic,   
> DCBX propagation in MF modes, handling of fan failures,
> removing napi struct from the stack and performs some code clean-ups. 
> 
> Please consider applying the series to net-next.

Applied, thanks.
