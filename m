From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/2] net: sh-eth: Use pr_err instead of printk
Date: Mon, 28 Jan 2013 10:41:57 +0900
Message-ID: <20130128014157.GC27896@verge.net.au>
References: <1350350279-8693-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <1350350279-8693-2-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <20130128012640.GB27896@verge.net.au>
 <20130127.202855.2183638663551956921.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nobuhiro.iwamatsu.yj@renesas.com, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:48490 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756501Ab3A1BmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 20:42:05 -0500
Content-Disposition: inline
In-Reply-To: <20130127.202855.2183638663551956921.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 27, 2013 at 08:28:55PM -0500, David Miller wrote:
> From: Simon Horman <horms@verge.net.au>
> Date: Mon, 28 Jan 2013 10:26:40 +0900
> 
> > [Cc David Miller, linux-sh]
> > 
> > On Tue, Oct 16, 2012 at 10:17:59AM +0900, Nobuhiro Iwamatsu wrote:
> >> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> > 
> > Acked-by: Simon Horman <horms+renesas@verge.net.au>
> > 
> > Dave, I know this is an oldie, but it appears to still be a goodie.
> > Could you consider it for 3.8?
> 
> Why would I consider it for 3.8?  We're in critical-but-fix-only
> state and this just modifies kernel log messages in what should
> be rare error paths, so entirely not appropriate for 3.8

Sorry, I'll repost it for 3.9 at a later date.
