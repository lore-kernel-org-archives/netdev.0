From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [cdc_ncm] guidance and help refactoring cdc_ncm
Date: Mon, 01 Jun 2015 12:49:38 +0200
Message-ID: <1433155778.1884.12.camel@suse.de>
References: <alpine.LNX.2.20.1505311628420.16456@localhost.localdomain>
	 <20150601005917.GB5320@kroah.com>
	 <alpine.LNX.2.20.1506010818110.3158@localhost.localdomain>
	 <1433144906.1557.2.camel@suse.com>
	 <alpine.LNX.2.20.1506011020001.3741@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: youtux@gmail.com, Greg KH <greg@kroah.com>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38857 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751322AbbFAKub (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jun 2015 06:50:31 -0400
In-Reply-To: <alpine.LNX.2.20.1506011020001.3741@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-06-01 at 10:24 +0200, Enrico Mioso wrote:
> We are failing on some cases only because of the position we put the
> NDP part 
> of the NCM frame. Infact, this 32-bit driver will work when the 16 bit
> one 
> does, and fail when the 16 bit one does.

I think the discussion would benefit from a clearer explanation
how those devices need an aggregate to look and how our aggregates
look like.

	Regards
		Oliver
