From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] cdc-ether: clean packet filter upon probe
Date: Mon, 28 Jul 2014 11:22:02 +0200
Message-ID: <1406539322.17754.13.camel@linux-fkkt.site>
References: <1406202989-8047-1-git-send-email-oneukum@suse.de>
	 <20140727.223013.144325831197355256.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48410 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751057AbaG1JWf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jul 2014 05:22:35 -0400
In-Reply-To: <20140727.223013.144325831197355256.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-07-27 at 22:30 -0700, David Miller wrote:
> From: Oliver Neukum <oneukum@suse.de>
> Date: Thu, 24 Jul 2014 13:56:29 +0200
> 
> > +			1000 /* out of thin air */
> 
> Just use USB_CTRL_SET_TIMEOUT if you can't come up with a specific
> reason to use another value.
> 
> Thanks.

Certainly

	Sorry
		Oliver
