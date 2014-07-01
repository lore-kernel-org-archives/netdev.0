From: Edward Allcutt <edward.allcutt@openmarket.com>
Subject: Re: [PATCH] ipv4: icmp: Fix pMTU handling for rare case
Date: Tue, 1 Jul 2014 20:38:07 +0100 (BST)
Message-ID: <alpine.DEB.2.10.1407012020011.5997@tabini.allcutt.me.uk>
References: <alpine.DEB.2.10.1407010937120.5997@tabini.allcutt.me.uk> <20140701.110510.2218293817137911715.davem@davemloft.net> <alpine.DEB.2.10.1407011912440.5997@tabini.allcutt.me.uk> <20140701.120730.2210532934459689553.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Edward Allcutt <edward.allcutt@openmarket.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140701.120730.2210532934459689553.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Jul 2014, David Miller wrote:
> I didn't say I won't apply the patch, actually the email you are
> replying to is strictly about figuring out what's happening on
> the OpenBSD systems for their sake.

Ah, sorry for the misunderstanding.

I'll see if I can find the place in the BSD code. Although I think in 
principle this could come up in other "technically correct" router 
implementations.

-- 
Edward Allcutt
