From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7] af_unix: Move CINQ/COUTQ code to helpers
Date: Fri, 30 Dec 2011 16:47:31 -0500 (EST)
Message-ID: <20111230.164731.1792998467702400955.davem@davemloft.net>
References: <4EFD9853.7090601@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44345 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744Ab1L3Vrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2011 16:47:35 -0500
In-Reply-To: <4EFD9853.7090601@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Fri, 30 Dec 2011 14:54:11 +0400

> Currently tcp diag reports rqlen and wqlen values similar to how
> the CINQ/COUTQ iotcls do. To make unix diag report these values 
> in the same way move the respective code into helpers.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Applied with some minor indentation fixes, thanks.
