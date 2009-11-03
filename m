From: Greg KH <gregkh@suse.de>
Subject: Re: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Mon, 2 Nov 2009 19:34:28 -0800
Message-ID: <20091103033428.GA19413@suse.de>
References: <200911010503.nA153Elp019063@blc-10-10.brocade.com> <1257053039.1917.147.camel@Joe-Laptop.home> <20091101112553.1dc0e3a9@nehalam> <1B6CC3D5ACAB014C8BFB6CB1CBD62CADD2835E9830@HQ-EXCH-7.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Joe Perches <joe@perches.com>, Rasesh Mody <rmody@brocade.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Adapter Linux Open SRC Team
	<adapter_linux_open_src_team@Brocade.COM>
To: Debashis Dutt <ddutt@Brocade.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:57795 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757892AbZKCD6Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 22:58:16 -0500
Content-Disposition: inline
In-Reply-To: <1B6CC3D5ACAB014C8BFB6CB1CBD62CADD2835E9830@HQ-EXCH-7.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 02, 2009 at 07:14:20PM -0800, Debashis Dutt wrote:
> Hi Stephen, 
> 
> This driver is written explicitly for Linux and we are working on addressing your
> comments.
> 
> Please let us know, if we need to look at some other areas.

Do you want me to put it in the drivers/staging/ tree now so you will
have a place to work on it in the kernel tree and others can use it as
well?

thanks,

greg k-h
