From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] MAINTAINERS: add entry for Xen network backend
Date: Mon, 04 Apr 2011 02:07:48 -0700 (PDT)
Message-ID: <20110404.020748.212408124.davem@davemloft.net>
References: <1301905567-7880-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	xen-devel@lists.xensource.com, akpm@linux-foundation.org,
	torvalds@linux-foundation.org
To: ian.campbell@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1301905567-7880-1-git-send-email-ian.campbell@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ian Campbell <ian.campbell@citrix.com>
Date: Mon,  4 Apr 2011 09:26:07 +0100

> +XEN NETWORK BACKEND DRIVER
> +M:	Ian Campbell <ian.campbell@citrix.com>
> +L:	xen-devel@lists.xensource.com (moderated for non-subscribers)
> +S:	Supported
> +F:	drivers/net/xen-netback/*
> +

To me there isn't much reason to have patch and other discussions
about a network driver on a moderated XEN list (which the majority of
core network developers are not subscribed to).

If anything, list both.  But not listing netdev is pretty pointless.
