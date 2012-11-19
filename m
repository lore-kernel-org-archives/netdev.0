From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: Remove the spurious \ in __ip_vs_lblc_init
Date: Mon, 19 Nov 2012 14:20:54 -0500 (EST)
Message-ID: <20121119.142054.1730676154409424743.davem@davemloft.net>
References: <87zk2d7gwp.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60605 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754021Ab2KSTU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 14:20:56 -0500
In-Reply-To: <87zk2d7gwp.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 19 Nov 2012 07:26:30 -0800

> 
> In (464dc801c76a net: Don't export sysctls to unprivileged users)
> I typoed and introduced a spurious backslash.  Delete it.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied.
