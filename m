From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] sock_diag: Arrange sock_diag.h such that it is
 exportable to userspace
Date: Fri, 30 Dec 2011 16:46:45 -0500 (EST)
Message-ID: <20111230.164645.2161392872448429854.davem@davemloft.net>
References: <4EFD97E5.6080701@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44320 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744Ab1L3Vqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2011 16:46:52 -0500
In-Reply-To: <4EFD97E5.6080701@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Fri, 30 Dec 2011 14:52:21 +0400

> Properly toss existing components around the ifdef __KERNEL__
> and include the header into the header-y target.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Applied.
