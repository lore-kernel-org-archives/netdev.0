From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging: r8188eu: Fix missing header
Date: Fri, 7 Feb 2014 16:04:23 -0800
Message-ID: <20140208000423.GB17796@kroah.com>
References: <1391814730-3461-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:60279 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868AbaBHADN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 19:03:13 -0500
Content-Disposition: inline
In-Reply-To: <1391814730-3461-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 07, 2014 at 05:12:10PM -0600, Larry Finger wrote:
> Commit 2397c6e0927675d983b34a03401affdb64818d07 entitled "staging: r8188eu:
> Remove wrappers around vmalloc and vzalloc" and
> commit: 03bd6aea7ba610a1a19f840c373624b8b0adde0d entitled "staging: r8188eu:
> Remove wrappers around vfree" failed to add the header file needed
> to provide vzalloc and vfree.
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

Was this reported by the 0-day bot?  If so, please credit it.

thanks,

greg k-h
