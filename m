From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: PATCH 2.6.27 update first comment in tulip files
Date: Tue, 24 Jun 2008 23:09:14 -0400
Message-ID: <4861B6DA.90304@pobox.com>
References: <20080605063855.GA20609@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48103 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753815AbYFYDJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 23:09:18 -0400
In-Reply-To: <20080605063855.GA20609@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Grundler wrote:
> Three basic changes to the comments at the top of each file:
> 1) remove stale "Maintained by" line...I prefer people look in MAINTAINERS.
> 2) Drop reference to stale sf.net/tulip website (I didn't see anything
>    of value there)
> 3) Point people at bugzilla.kernel.org to submit bugs...will always
>    get tracked regardless of who the maintainer is.
> 
> Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
> 
> ---
> Jeff,
> This is intended for 2.6.27 once the merge window opens.
> Patch is actually against 2.6.26-rc4.

applied

For future patches, please enclose the "PATCH 2.6.27" in the subject 
line in brackets ("[", "]").  The text inside the brackets is 
automatically swallowed by patch processing tools.  For more info on 
patch format see #14 of
Documentation/SubmittingPatches or http://linux.yyz.us/patch-format.html

Thanks,

	Jeff



