From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NPROTO is redundant; it's equal to AF_MAX/PF_MAX.
Date: Sat, 22 Mar 2008 17:19:00 -0700 (PDT)
Message-ID: <20080322.171900.16160131.davem@davemloft.net>
References: <200803121834.26493.rusty@rustcorp.com.au>
	<20080312.041318.193687381.davem@davemloft.net>
	<200803131050.13790.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40812
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753260AbYCWASr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2008 20:18:47 -0400
In-Reply-To: <200803131050.13790.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 13 Mar 2008 10:50:13 +1100

> DaveM pointed out NPROTO exposed to userspace, so keep it around,
> just make sure it stays in sync.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Applied to net-2.6.26, thanks Rusty.
