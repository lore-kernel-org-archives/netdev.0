From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: kill sk_dst_lock
Date: Wed, 02 Dec 2015 21:57:34 -0800
Message-ID: <1449122254.6379.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1448731434.24696.97.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448854142.24696.109.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448901315.24696.127.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151202.234216.1113392733011218992.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, vyasevich@gmail.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35645 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973AbbLCF5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 00:57:35 -0500
Received: by pacej9 with SMTP id ej9so61710320pac.2
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 21:57:35 -0800 (PST)
In-Reply-To: <20151202.234216.1113392733011218992.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-12-02 at 23:42 -0500, David Miller wrote:

> Please update the commit log message with the details you
> provided in a reply to this thread.

Sure, I sent a v2.

Thanks.
