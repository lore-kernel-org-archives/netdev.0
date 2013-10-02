From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: sndbuf autotuning improvements
Date: Wed, 02 Oct 2013 14:07:36 -0700
Message-ID: <1380748056.19002.124.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380648224.19002.32.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131002.164600.347083935801850982.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com,
	maze@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:35957 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754020Ab3JBVHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 17:07:38 -0400
Received: by mail-pb0-f41.google.com with SMTP id rp2so1461235pbb.28
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 14:07:37 -0700 (PDT)
In-Reply-To: <20131002.164600.347083935801850982.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-02 at 16:46 -0400, David Miller wrote:

> I assume this is meant for net-next as that is where this applies
> cleanly.
> 
> Applied, thanks.

Indeed, sorry for missing net-next tag.

Thanks !
