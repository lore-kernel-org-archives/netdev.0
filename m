From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH] NET: ASSERT_RTNL in __dev_set_promiscuity makes debug warning
Date: Wed, 5 Dec 2007 14:56:04 +0900
Message-ID: <b25c3fa70712042156h27043f47k5e3959be01a1234a@mail.gmail.com>
References: <000001c8365a$e0e500c0$9c94fea9@jason>
	 <E1IzgPL-0006HB-00@gondolin.me.apana.org.au>
	 <006001c836ff$f0d59a30$9c94fea9@jason>
	 <20071205053607.GA10589@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David Miller" <davem@davemloft.net>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.190]:19077 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbXLEF4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 00:56:04 -0500
Received: by rv-out-0910.google.com with SMTP id k20so3481827rvb
        for <netdev@vger.kernel.org>; Tue, 04 Dec 2007 21:56:04 -0800 (PST)
In-Reply-To: <20071205053607.GA10589@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2007/12/5, Herbert Xu <herbert@gondor.apana.org.au>:
> The idea is to not touch the unicast stuff at all on the multicast path.
>
> Anyway, this was discussed on netdev so please check the archives because
> there is more to this than just changing the multicast handling.  We also
> talked about consolidating the driver interface so that all these calls
> have the same environment rather than the mix-and-match that we have now.
>

Thanks again Herbert,
I'll take a look at old discussions.

Thanks.
Joonwoo
