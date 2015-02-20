From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4: Fix incorrect 'c' suffix to %pI4, use %pISc
 instead
Date: Fri, 20 Feb 2015 17:26:16 -0500 (EST)
Message-ID: <20150220.172616.1120531128343853051.davem@davemloft.net>
References: <1424302185-13460-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com,
	dan.carpenter@gmail.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47423 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752745AbbBTW0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 17:26:19 -0500
In-Reply-To: <1424302185-13460-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Wed, 18 Feb 2015 15:29:45 -0800

> Issue caught by 0-day kernel test infrastructure. Code changed to use sockaddr
> members so that %pISc can be used instead.
> 
> Fixes: b5a02f503caa ('cxgb4 : Update ipv6 address handling api')
> 
> Signed-off-by: Anish Bhatt <anish@chelsio.com>

Applied, thanks.
