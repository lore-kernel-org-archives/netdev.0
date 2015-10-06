From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] bridge/netfilter: avoid unused label warning
Date: Tue, 06 Oct 2015 21:39:13 +0200
Message-ID: <5966552.c0Emgm27oa@wuerfel>
References: <7985748.1v9Gzszd4T@wuerfel> <561420DD.70009@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <561420DD.70009@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 06 October 2015 21:28:29 Nikolay Aleksandrov wrote:
> I posted a fix for this a couple of days ago, but I like your approach better.
> Since mine is not yet applied (I sent it to netfilter-devel only, wasn't sure which
> jurisdiction this falls into exactly) we can drop it.
> Just for reference my patch is here:
> http://patchwork.ozlabs.org/patch/526417/
> Pablo, could you please drop it ?
> 
> By the way this takes care of another warning about unused variable (nf_bridge), too.

Hmm I did not get that one, at least not in 4.3-rc4.

> Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Thanks and sorry for missing the Cc to the netfilter list on my patch.

	Arnd
