From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v1] ipv6/ila: fix nlsize calculation for lwtunnel
Date: Tue, 03 May 2016 16:22:18 -0400 (EDT)
Message-ID: <20160503.162218.1350660783620997400.davem@davemloft.net>
References: <CALx6S36jkPqx5U+B9akRYZ+xiRhozk_AdOmKBEr4N9mhwTKQMw@mail.gmail.com>
	<1462262307-27498-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52654 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756181AbcECUWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 16:22:19 -0400
In-Reply-To: <1462262307-27498-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue,  3 May 2016 09:58:27 +0200

> The handler 'ila_fill_encap_info' adds one attribute: ILA_ATTR_LOCATOR.
> 
> Fixes: 65d7ab8de582 ("net: Identifier Locator Addressing module")
> CC: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
> 
> RFC -> v1:
>   - rebase on last net tree

Applied and queued up for -stable, thanks for reposting this Nicolas.
