From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: Make fib_encap_match static
Date: Thu, 20 Aug 2015 14:12:38 -0700 (PDT)
Message-ID: <20150820.141238.1181985199050039024.davem@davemloft.net>
References: <1439971491-16210-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57224 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129AbbHTVMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 17:12:39 -0400
In-Reply-To: <1439971491-16210-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Wed, 19 Aug 2015 16:04:51 +0800

> Make fib_encap_match() static as it isn't used outside the file.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Applied.
