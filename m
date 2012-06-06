From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 4/6] netfilter: ipv4, defrag: switch hook PFs to nfproto
Date: Wed, 6 Jun 2012 02:03:23 +0200
Message-ID: <20120606000323.GD27266@1984>
References: <1337003799-2517-1-git-send-email-alban.crequy@collabora.co.uk>
 <1337003799-2517-4-git-send-email-alban.crequy@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Vincent Sanders <vincent.sanders@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50682 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753909Ab2FFADZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2012 20:03:25 -0400
Content-Disposition: inline
In-Reply-To: <1337003799-2517-4-git-send-email-alban.crequy@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 14, 2012 at 02:56:37PM +0100, Alban Crequy wrote:
> NFPROTO_* constants were usually equal to PF_* constants but it is not
> necessary and it will waste less memory if we don't do so (see commit 7e9c6e
> "netfilter: Introduce NFPROTO_* constants")

Applied (with that description rewrite as said), thanks.
