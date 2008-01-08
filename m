From: maximilian attems <max@stro.at>
Subject: Re: [PATCH] AX25: nuke user trigable printks
Date: Tue, 8 Jan 2008 10:21:55 +0100
Message-ID: <20080108092154.GP8816@baikonur.stro.at>
References: <1199728513-25258-1-git-send-email-max@stro.at> <20080107.215550.08459948.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:60723 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330AbYAHJWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 04:22:40 -0500
Content-Disposition: inline
In-Reply-To: <20080107.215550.08459948.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 07, 2008 at 09:55:50PM -0800, David Miller wrote:
> 
> Can you replace the printk()'s with comments at least?
> 
> Otherwise nobody is going to remember what we were trying
> to accomplish here and it will guarentee that, in fact,
> support for these old things will never get removed.
> 
> At least if comments are there, someone might think to add
> these things to the feature removal schedule and follow
> through with it.

sure will resend later.
wasn't sure myself of the chosen minimal user visible clean up.

thanks

-- 
maks

