From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: refactor sk_page_frag_refill()
Date: Thu, 17 Oct 2013 16:13:29 -0700
Message-ID: <1382051609.3284.0.camel@edumazet-glaptop.roam.corp.google.com>
References: <CANJ5vPJpVfDjaC8JauGYu=Qe4ZshqmBMkCbB1cru-xAfa7K1+g@mail.gmail.com>
	 <1381623952.3392.25.camel@edumazet-glaptop.roam.corp.google.com>
	 <1381639591.3392.31.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131017.154625.1687353288700164892.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mwdalton@google.com, dborkman@redhat.com, netdev@vger.kernel.org,
	ffusco@redhat.com, ycheng@google.com, ncardwell@google.com,
	digitaleric@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:48028 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752418Ab3JQXNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 19:13:32 -0400
Received: by mail-pa0-f52.google.com with SMTP id kl14so3539181pab.39
        for <netdev@vger.kernel.org>; Thu, 17 Oct 2013 16:13:31 -0700 (PDT)
In-Reply-To: <20131017.154625.1687353288700164892.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-17 at 15:46 -0400, David Miller wrote:

> Please rename this to something like "skb_page_frag_refill" so that it
> is clear that this is a networking interface.

Sure will do, thanks !
