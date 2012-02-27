From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: cleanup dependencies
Date: Mon, 27 Feb 2012 08:29:24 -0800
Message-ID: <20120227082924.303bc5f8@nehalam.linuxnetplumber.net>
References: <1330352475-31109-1-git-send-email-yegorslists@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yegorslists@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54403 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751124Ab2B0Q31 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Feb 2012 11:29:27 -0500
In-Reply-To: <1330352475-31109-1-git-send-email-yegorslists@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Feb 2012 15:21:15 +0100
yegorslists@googlemail.com wrote:

> From: Yegor Yefremov <yegorslists@googlemail.com>
> 
> LIBNETLINK will be defined in the main Makefile, so
> both ../lib/libnetlink.a ../lib/libutil.a will be
> automatically appended during linking. Otherwise
> ../lib/libnetlink.a ../lib/libutil.a will appear
> twice during linking.
> 
> Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>

Applied, thanks.
