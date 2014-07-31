From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] CAPI: use correct structure type name in sizeof
Date: Wed, 30 Jul 2014 19:14:05 -0700 (PDT)
Message-ID: <20140730.191405.497343033042623279.davem@davemloft.net>
References: <1406647011-8543-1-git-send-email-Julia.Lawall@lip6.fr>
	<1406647011-8543-3-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, kernel-janitors@vger.kernel.org,
	linux-ia64@vger.kernel.org, ceph-devel@vger.kernel.org,
	toralf.foerster@gmx.de, hmh@hmh.eng.br, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-ia64-owner@vger.kernel.org>
In-Reply-To: <1406647011-8543-3-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Tue, 29 Jul 2014 17:16:44 +0200

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Correct typo in the name of the type given to sizeof.  Because it is the
> size of a pointer that is wanted, the typo has no impact on compilation or
> execution.
> 
> This problem was found using Coccinelle (http://coccinelle.lip6.fr/).  The
> semantic patch used can be found in message 0 of this patch series.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Relatively harmless, so applied to net-next, thanks.
