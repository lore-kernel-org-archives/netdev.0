From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] bonding: allow TSO being set on bonding master
Date: Thu, 16 May 2013 15:16:54 -0700
Message-ID: <1368742614.3301.61.camel@edumazet-glaptop>
References: <1368654065.4519.53.camel@edumazet-glaptop>
	 <1368725693.3301.59.camel@edumazet-glaptop>
	 <20130516.150239.2187164031807939707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mirqus@gmail.com, netdev@vger.kernel.org, fubar@us.ibm.com,
	maze@google.com, andy@greyhouse.net, therbert@google.com,
	ncardwell@google.com, ycheng@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:40208 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755001Ab3EPWRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 18:17:02 -0400
Received: by mail-pd0-f176.google.com with SMTP id x10so2741561pdj.35
        for <netdev@vger.kernel.org>; Thu, 16 May 2013 15:17:01 -0700 (PDT)
In-Reply-To: <20130516.150239.2187164031807939707.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-16 at 15:02 -0700, David Miller wrote:

> Applied, but:
> 
> > +static inline netdev_features_t netdev_add_tso_features(netdev_features_t features,
> > +	netdev_features_t mask)
> 
> I fixed the mask argument indentation when I commited this.
> 
> Thakns.

I sorry, I think I used the convention of the above function.

Thanks !
