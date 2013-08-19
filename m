From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch -next] ipip: dereferencing an ERR_PTR in
 ip_tunnel_init_net()
Date: Mon, 19 Aug 2013 16:49:01 +0300
Message-ID: <20130819134901.GH22811@mwanda>
References: <20130819070510.GE28591@elgon.mountain>
 <1376917088.4226.50.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:31168 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796Ab3HSNts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 09:49:48 -0400
Content-Disposition: inline
In-Reply-To: <1376917088.4226.50.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the review.  I will send a v2 patch shortly.

regards,
dan carpenter
