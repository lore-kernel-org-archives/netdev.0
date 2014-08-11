From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 4/5] netfilter: nf_tables: fix error return code
Date: Mon, 11 Aug 2014 18:41:14 +0200
Message-ID: <20140811164114.GA7770@salvia>
References: <1407415749-19978-1-git-send-email-Julia.Lawall@lip6.fr>
 <1407415749-19978-5-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37272 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753127AbaHKQlA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2014 12:41:00 -0400
Content-Disposition: inline
In-Reply-To: <1407415749-19978-5-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 07, 2014 at 02:49:08PM +0200, Julia Lawall wrote:
> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Convert a zero return value on error to a negative one, as returned
> elsewhere in the function.

Applied, thanks Julia.
