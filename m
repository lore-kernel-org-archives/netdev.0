From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] net: dev: reduce both ingress hook ifdefs
Date: Wed, 20 May 2015 14:39:11 +0200
Message-ID: <20150520123911.GA23133@salvia>
References: <3898d6056534c7fc4d43a9e6d27488bffb72b657.1432067241.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, ast@plumgrid.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33882 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753328AbbETMeU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 May 2015 08:34:20 -0400
Content-Disposition: inline
In-Reply-To: <3898d6056534c7fc4d43a9e6d27488bffb72b657.1432067241.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2015 at 10:33:25PM +0200, Daniel Borkmann wrote:
> Reduce ifdef pollution slightly, no functional change. We can simply
> remove the extra alternative definition of handle_ing() and nf_ingress().
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
