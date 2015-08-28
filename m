From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next v5 00/11] ipv6: Only create RTF_CACHE route
 after encountering pmtu exception
Date: Fri, 28 Aug 2015 00:36:38 -0700
Message-ID: <20150828073429.GA67211@kafai-mba.gkf168.com>
References: <1432353366-2296465-1-git-send-email-kafai@fb.com>
 <55B89C14.2070700@ahsoftware.de>
 <55BA1144.9090203@ahsoftware.de>
 <55CEEECA.8000702@ahsoftware.de>
 <55D1ACB8.3040500@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Kernel Team <Kernel-team@fb.com>, <stable@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Alexander Holler <holler@ahsoftware.de>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55D1ACB8.3040500@ahsoftware.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 17, 2015 at 11:43:20AM +0200, Alexander Holler wrote:
> That's why I vote to check out if it's possible/reasonable to backport this
> series to the stable kernels.
I have backported to 4.0.y without major issue, so possible.

I did try on 3.1x and gave up.

It is a lot of changes,  so I don't think it is a good idea for -stable.

Thanks,
Martin
