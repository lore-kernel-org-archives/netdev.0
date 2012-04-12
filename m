From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv6/ipv6_sockglue.c: Removed redundant extern
Date: Thu, 12 Apr 2012 16:15:15 -0400 (EDT)
Message-ID: <20120412.161515.268929016632579152.davem@davemloft.net>
References: <1334083887-5375-1-git-send-email-eldad@fogrefinery.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: eldad@fogrefinery.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334083887-5375-1-git-send-email-eldad@fogrefinery.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eldad Zack <eldad@fogrefinery.com>
Date: Tue, 10 Apr 2012 20:51:27 +0200

> extern int sysctl_mld_max_msf is already defined in linux/ipv6.h.
> 
> Signed-off-by: Eldad Zack <eldad@fogrefinery.com>

Applied, thanks.
