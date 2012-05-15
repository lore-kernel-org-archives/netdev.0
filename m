From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm_algo: drop an unnecessary inclusion
Date: Tue, 15 May 2012 13:14:48 -0400 (EDT)
Message-ID: <20120515.131448.1788192704023213475.davem@davemloft.net>
References: <4FB2618C0200007800083C99@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: JBeulich@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40286 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964815Ab2EORPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 13:15:08 -0400
In-Reply-To: <4FB2618C0200007800083C99@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jan Beulich" <JBeulich@suse.com>
Date: Tue, 15 May 2012 13:00:44 +0100

> For several releases, this has not been needed anymore, as no helper
> functions declared in net/ah.h get implemented by xfrm_algo.c anymore.
> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>

Applied.
