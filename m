From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/7] bnx2x: fixes
Date: Thu, 01 Nov 2012 11:33:32 -0400 (EDT)
Message-ID: <20121101.113332.1207351200542579348.davem@davemloft.net>
References: <1351698418-10005-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com, netdev@vger.kernel.org
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60285 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755404Ab2KAPde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 11:33:34 -0400
In-Reply-To: <1351698418-10005-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Wed, 31 Oct 2012 17:46:51 +0200

> Please consider applying the series of fixes to net.
> 
> Dmitry Kravkov (1):
>       bnx2x: disable FCoE for 57840 since not yet supported by FW
> 
> Yaniv Rosner (6):
>       bnx2x: Fix 57810 1G-KR link against certain switches.
>       bnx2x: Fix link down in 57712 following LFA
>       bnx2x: Restore global registers back to default.
>       bnx2x: Fix potential incorrect link speed provision
>       bnx2x: Fix unrecognized SFP+ module after driver is loaded
>       bnx2x: Fix no link on 577xx 10G-baseT

Series applied, thanks.
