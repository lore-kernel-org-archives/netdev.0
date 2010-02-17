From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 0/2] Staging: Clean up octeon Ethernet some.
Date: Tue, 16 Feb 2010 20:58:44 -0800
Message-ID: <20100217045844.GB18306@suse.de>
References: <4B7B4540.1010700@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>,
	linux-mips <linux-mips@linux-mips.org>,
	Netdev <netdev@vger.kernel.org>
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:59181 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934042Ab0BQE7Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2010 23:59:25 -0500
Content-Disposition: inline
In-Reply-To: <4B7B4540.1010700@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 16, 2010 at 05:24:16PM -0800, David Daney wrote:
> These two patches clean up some comments and get rid of the code that
> creates a non-standard file in /proc
> 
> As with the previous octeon_ethernet patches, these can probably go
> via Ralf's linux-mips.org tree.

Going through Ralf's tree is fine for me.

thanks,

greg k-h
