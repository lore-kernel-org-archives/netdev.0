From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipsec: update MAX_AH_AUTH_LEN to support sha512
Date: Thu, 13 Jan 2011 21:50:13 -0800 (PST)
Message-ID: <20110113.215013.200622136.davem@davemloft.net>
References: <4D2F73C7.8010107@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49927
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751939Ab1ANFtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 00:49:41 -0500
In-Reply-To: <4D2F73C7.8010107@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 13 Jan 2011 22:51:03 +0100

>>From e330817aa2b33e9d1f44071072fdc4778acf8d76 Mon Sep 17 00:00:00 2001
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Thu, 13 Jan 2011 14:20:19 -0500
> Subject: [PATCH] ipsec: update MAX_AH_AUTH_LEN to support sha512
> 
> icv_truncbits is set to 256 for sha512, so update
> MAX_AH_AUTH_LEN to 64.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
