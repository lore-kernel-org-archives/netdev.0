From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sched: fix typo in net_device ifdef
Date: Mon, 11 May 2015 13:37:53 -0400 (EDT)
Message-ID: <20150511.133753.865439786568159663.davem@davemloft.net>
References: <45ab7891f81f127f688ac20fdac86d5c13afed57.1431364704.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, ast@plumgrid.com, jhs@mojatatu.com,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35905 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527AbbEKRh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 13:37:56 -0400
In-Reply-To: <45ab7891f81f127f688ac20fdac86d5c13afed57.1431364704.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 11 May 2015 19:28:49 +0200

> This should have been #ifdef not #if.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Fixes: d2788d34885d ("net: sched: further simplify handle_ing")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  Very sorry for the typo.

Applied, thanks Daniel.
