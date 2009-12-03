From: David Miller <davem@davemloft.net>
Subject: Re: [patch]reset_resume for cdc-ether
Date: Wed, 02 Dec 2009 22:16:27 -0800 (PST)
Message-ID: <20091202.221627.133392199.davem@davemloft.net>
References: <200911241159.02098.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david-b@pacbell.net, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37825
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751425AbZLCGQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 01:16:21 -0500
In-Reply-To: <200911241159.02098.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oliver@neukum.org>
Date: Tue, 24 Nov 2009 11:59:02 +0100

> Hi,
> 
> this is quite trivial but might be convenient to many users.
> 
> 	Regards
> 		Oliver
> 
> Signed-off-by: Oliver Neukum <oliver@neukum.org>

I'm going to apply this patch and the USB autosuspend one too.

If David B. has some problems with it, we can revert.  But as it
stands these patches have been posted for some time and there's
no reason for them to miss the merge window so I'm adding them
to net-next-2.6

Thanks Oliver.
