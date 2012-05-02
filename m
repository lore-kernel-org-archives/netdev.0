From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] netfilter: xt_recent: Add optional mask option for
 xt_recent
Date: Wed, 2 May 2012 02:56:05 +0200
Message-ID: <20120502005605.GA15074@1984>
References: <1331033084-23803-1-git-send-email-denys@visp.net.lb>
 <20120411231421.GA7038@1984>
 <d8de90a8f08a092730109e72827264fe@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <d8de90a8f08a092730109e72827264fe@visp.net.lb>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 12, 2012 at 12:00:03PM +0300, Denys Fedoryshchenko wrote:
[...]
> For me personally it is useful, because i have around 140 NAS
> servers, and i give each of them /24 "gray" subnets, and in some
> cases i need to handle bad users, that are changing dynamic ip and
> attacking from new ip each time. I just block non-critical service
> for whole subnet then, till technician on duty will solve issue
> completely. And sure if attack are stopped, subnet will be unblocked
> "automagically".

OK, if you need this, I'm fine with it.

> Sure this feature not critical, or "a must", and if code are not
> good, it is up to you, if it should be added or not.

I didn't say anything about the code yet. E-mail reviewing this will
follow.
