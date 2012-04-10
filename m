From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 03/10] chelsio: use SKB_WITH_OVERHEAD
Date: Tue, 10 Apr 2012 16:59:43 +0200
Message-ID: <1334069983.5300.56.camel@edumazet-glaptop>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
	 <1334067984-7706-3-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xen.org,
	Divy Le Ray <divy@chelsio.com>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:50575 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753468Ab2DJO7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 10:59:51 -0400
Received: by bkcik5 with SMTP id ik5so4303530bkc.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 07:59:49 -0700 (PDT)
In-Reply-To: <1334067984-7706-3-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-10 at 15:26 +0100, Ian Campbell wrote:
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: Divy Le Ray <divy@chelsio.com>
> ---
>  drivers/net/ethernet/chelsio/cxgb/sge.c  |    3 +--
>  drivers/net/ethernet/chelsio/cxgb3/sge.c |    6 +++---
>  2 files changed, 4 insertions(+), 5 deletions(-)
> 
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
