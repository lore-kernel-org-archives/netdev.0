From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: icmp: Fix pMTU handling for rare case
Date: Wed, 02 Jul 2014 12:14:29 -0700 (PDT)
Message-ID: <20140702.121429.1078505008114493555.davem@davemloft.net>
References: <alpine.DEB.2.10.1407010937120.5997@tabini.allcutt.me.uk>
	<20140701.110510.2218293817137911715.davem@davemloft.net>
	<alpine.DEB.2.10.1407020954250.5997@tabini.allcutt.me.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: edward.allcutt@openmarket.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1407020954250.5997@tabini.allcutt.me.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Edward Allcutt <edward.allcutt@openmarket.com>
Date: Wed, 2 Jul 2014 10:05:13 +0100 (BST)

> On Tue, 1 Jul 2014, David Miller wrote:
>> I still think the OpenBSD thing can't be intentional, and it's some
>> bug they probably want to fix and it should therefore be investigated.
> 
> Shout at me if this is getting too off-topic..

It's something you should tell the OpenBSD folks about, more importantly
than us :)
