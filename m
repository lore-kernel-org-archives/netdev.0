From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: Patch to fix scheduling while atomic splat
Date: Tue, 25 Nov 2014 09:23:31 -0800
Message-ID: <20141125172331.GC16005@kroah.com>
References: <5474B234.9090701@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org >> netdev" <netdev@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:45755 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbaKYRXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 12:23:31 -0500
Content-Disposition: inline
In-Reply-To: <5474B234.9090701@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 10:45:40AM -0600, Larry Finger wrote:
> Greg,
> 
> On Nov. 12, I sent a patch for kernel 3.18 with the subject "[PATCH for
> 3.18] staging: r8188eu: Fix scheduling while atomic error introduced in
> commit fadbe0cd". To date, this fix does not seem to have appeared in
> mainline. Did it get missed?

No, it's in my queue of 500+ other staging patches to be reviewed,
sorry.  Hope to get to that queue soon.

greg k-h
