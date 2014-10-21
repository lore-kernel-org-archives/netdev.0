From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] net: sched: initialize bstats syncp
Date: Tue, 21 Oct 2014 11:52:48 -0700
Message-ID: <CAHA+R7OcT7U3+xUOYkGAucVmXUvjO6q5BmMw8MwB-6b4vbi_aA@mail.gmail.com>
References: <20141021092330.GA9863@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:33930 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930AbaJUSwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2014 14:52:54 -0400
Received: by mail-qc0-f176.google.com with SMTP id r5so1425933qcx.21
        for <netdev@vger.kernel.org>; Tue, 21 Oct 2014 11:52:50 -0700 (PDT)
In-Reply-To: <20141021092330.GA9863@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 21, 2014 at 2:23 AM, Sabrina Dubroca <sd@queasysnail.net> wrote:
> Use netdev_alloc_pcpu_stats to allocate percpu stats and initialize syncp.
>
> Fixes: 22e0f8b9322c "net: sched: make bstats per cpu and estimator RCU safe"
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Acked-by: Cong Wang <cwang@twopensource.com>
