From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] unix_diag: Include unix_diag.h into header-y target
Date: Fri, 30 Dec 2011 16:46:54 -0500 (EST)
Message-ID: <20111230.164654.187467235176041323.davem@davemloft.net>
References: <4EFD9803.3040106@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44324 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744Ab1L3Vq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2011 16:46:57 -0500
In-Reply-To: <4EFD9803.3040106@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Fri, 30 Dec 2011 14:52:51 +0400

> The headers check complains it should include the linux/types.h
> withing, thus add this one.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Applied.
