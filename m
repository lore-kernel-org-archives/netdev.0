From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 0/4] Improvements to octeon_ethernet.
Date: Mon, 15 Feb 2010 13:05:58 -0800
Message-ID: <20100215210558.GA27325@suse.de>
References: <4B79AAA6.60005@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ralf.baechle@gmail.com, linux-mips <linux-mips@linux-mips.org>,
	Netdev <netdev@vger.kernel.org>
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:47901 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932147Ab0BOVlr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2010 16:41:47 -0500
Content-Disposition: inline
In-Reply-To: <4B79AAA6.60005@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 15, 2010 at 12:12:22PM -0800, David Daney wrote:
> Here are a couple of improvements to the octeon_ethernet in
> drivers/staging/octeon.  The first patch is just cleanup, the rest are
> genuine bug fixes.
>
> I will reply with the four patches.
>
> We may want to merge via Ralf's linux-mips.org tree as Octeon is
> infact a MIPS based SOC and he has a bunch of other patches queued
> there that these depend on.

That's fine with me for them to go through that way.

thanks,

greg k-h
