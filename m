From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] sock_diag: Introduce the meminfo nla core (v2)
Date: Fri, 30 Dec 2011 16:47:00 -0500 (EST)
Message-ID: <20111230.164700.2112084254118828088.davem@davemloft.net>
References: <4EFD9819.1060701@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44332 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744Ab1L3VrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2011 16:47:04 -0500
In-Reply-To: <4EFD9819.1060701@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Fri, 30 Dec 2011 14:53:13 +0400

> Add a routine that dumps memory-related values of a socket.
> It's made as an array to make it possible to add more stuff
> here later without breaking compatibility.
> 
> Since v1: The SK_MEMINFO_ constants are in userspace
> visible part of sock_diag.h, the rest is under __KERNEL__.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Applied.
