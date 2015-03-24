From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5 net-next v2] rhashtable: Disable automatic
 shrinking by default
Date: Tue, 24 Mar 2015 18:01:27 -0400 (EDT)
Message-ID: <20150324.180127.2191929658904515752.davem@davemloft.net>
References: <f6ed6e9fe9434e55475b777281f6fe67eff0e07d.1427202823.git.tgraf@suug.ch>
	<20150324185545.GA15837@gondor.apana.org.au>
	<20150324204219.GA23613@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752072AbbCXWBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 18:01:31 -0400
In-Reply-To: <20150324204219.GA23613@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 24 Mar 2015 20:42:19 +0000

> Introduce a new bool automatic_shrinking to require the
> user to explicitly opt-in to automatic shrinking of tables.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
> v2: Use bool in params to also disable shrinking in worker as
>     pointed out by Herbert.
> 
> @Dave: Patch 5 still applied on top with some fuzz. If not,
>        let me know and I will respin.

Ok I applied this series with the updated patch #4, thanks!
