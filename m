From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/4 v3] bnx2x, cnic: support DRV_INFO upon FW
 request
Date: Tue, 06 Dec 2011 13:06:54 -0500 (EST)
Message-ID: <20111206.130654.1235461360535098349.davem@davemloft.net>
References: <1323160910-28446-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, barak@broadcom.com, eilong@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60003 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752682Ab1LFSG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 13:06:57 -0500
In-Reply-To: <1323160910-28446-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 6 Dec 2011 00:41:50 -0800

> From: Barak Witkowski <barak@broadcom.com>
> 
> Add support to send driver capabilities, settings and statistics to
> management firmware.
> 
> [ Redone using many local variables, removed many unnecessary inlines,
>   and put #defines at the left margin suggested by Joe Perches ]
> 
> Signed-off-by: Barak Witkowski <barak@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
