From: David Miller <davem@davemloft.net>
Subject: Re: netfilter: ctnetlink: fix GFP_KERNEL allocation under spinlock
Date: Wed, 26 Nov 2008 03:57:59 -0800 (PST)
Message-ID: <20081126.035759.83312310.davem@davemloft.net>
References: <492D319C.4060008@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <492D319C.4060008@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 26 Nov 2008 12:23:08 +0100

> This patch for 2.6.28 fixes a GFP_KERNEL allocation under spinlock
> in ctnetlink that was missed in the conntrack creation race fix.
> 
> Please apply, thanks.

Applied, thanks Patrick.
