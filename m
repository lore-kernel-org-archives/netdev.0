From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCHv2 RFC net-next 0/7] net: dst_confirm replacement
Date: Tue, 31 Jan 2017 23:53:17 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1701312350110.2064@ja.home.ssi.bg>
References: <1485613578-19973-1-git-send-email-ja@ssi.bg> <20170130.101339.2050288140097606206.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        yuehaibing@huawei.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:58123 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750805AbdAaVxe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Jan 2017 16:53:34 -0500
In-Reply-To: <20170130.101339.2050288140097606206.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 30 Jan 2017, David Miller wrote:

> From: Julian Anastasov <ja@ssi.bg>
> > 
> > 	So, the following solution is to avoid using
> > dst->pending_confirm.
> 
> For the most part this series looks good to me, nice work.

	OK, I'm posting v3 after removing the RFC tag from v2,
I just added the Acked-by tags.

Regards
