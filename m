From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dev: reduce both ingress hook ifdefs
Date: Thu, 21 May 2015 16:59:11 -0400 (EDT)
Message-ID: <20150521.165911.1242133829504621938.davem@davemloft.net>
References: <3898d6056534c7fc4d43a9e6d27488bffb72b657.1432067241.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, ast@plumgrid.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39741 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756507AbbEUU7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 16:59:14 -0400
In-Reply-To: <3898d6056534c7fc4d43a9e6d27488bffb72b657.1432067241.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue, 19 May 2015 22:33:25 +0200

> Reduce ifdef pollution slightly, no functional change. We can simply
> remove the extra alternative definition of handle_ing() and nf_ingress().
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Daniel.
