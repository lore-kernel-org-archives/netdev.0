From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bpf: add mod default A and X test cases
Date: Thu, 05 Nov 2015 00:06:08 -0500 (EST)
Message-ID: <20151105.000608.1775208283796100081.davem@davemloft.net>
References: <1446665797-21400-1-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, zlim.lnx@gmail.com,
	xi.wang@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linaro-kernel@lists.linaro.org
To: yang.shi@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60327 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbbKEFGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 00:06:11 -0500
In-Reply-To: <1446665797-21400-1-git-send-email-yang.shi@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Shi <yang.shi@linaro.org>
Date: Wed,  4 Nov 2015 11:36:37 -0800

> When running "mod X" operation, if X is 0 the filter has to be halt.
> Add new test cases to cover A = A mod X if X is 0, and A = A mod 1.
> 
> CC: Xi Wang <xi.wang@gmail.com>
> CC: Zi Shen Lim <zlim.lnx@gmail.com>
> Signed-off-by: Yang Shi <yang.shi@linaro.org>

Applied, thank you.
