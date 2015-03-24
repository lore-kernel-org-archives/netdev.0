From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: fix sparse warnings in privacy stable
 addresses generation
Date: Tue, 24 Mar 2015 15:21:59 -0400 (EDT)
Message-ID: <20150324.152159.44172822245737488.davem@davemloft.net>
References: <2c4b658a420789137afca51f5249fd15022a9383.1427191441.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752146AbbCXTWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 15:22:01 -0400
In-Reply-To: <2c4b658a420789137afca51f5249fd15022a9383.1427191441.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 24 Mar 2015 11:05:28 +0100

> Those warnings reported by sparse endianness check (via kbuild test robot)
> are harmless, nevertheless fix them up and make the code a little bit
> easier to read.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Fixes: 622c81d57b392cc ("ipv6: generation of stable privacy addresses for link-local and autoconf")
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
