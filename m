From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] [BACKPORT] [3.14.56] bnx2x: Don't notify about
 scratchpad parities
Date: Fri, 6 Nov 2015 09:32:46 -0800
Message-ID: <20151106173246.GA6771@kroah.com>
References: <2866398.tTChUFNQ37@rofl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: Patrick Schaaf <netdev@bof.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:43110 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932984AbbKFRcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 12:32:47 -0500
Content-Disposition: inline
In-Reply-To: <2866398.tTChUFNQ37@rofl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 05, 2015 at 11:18:37AM +0100, Patrick Schaaf wrote:
> bnx2x: Don't notify about scratchpad parities
> 
> This is a (trivial) "backport" of ad6afbe9578d1fa26680faf78c846bd8c00d1d6e to 
> stable kernel 3.14.56.

This patch isn't in 4.1 either, do you want it there as well?

thanks,

greg k-h
