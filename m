From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] MAINTAINERS: Orphan usb/net/hso driver
Date: Tue, 28 Feb 2017 18:51:24 +0100
Message-ID: <20170228175124.GA14016@kroah.com>
References: <30ad43134a6a7d155a257abaa31d120cf2c4d74c.1488271188.git.baruch@tkos.co.il>
 <20170228.103844.1220680109576438605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: baruch@tkos.co.il, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:33374 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751055AbdB1Rwe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 12:52:34 -0500
Content-Disposition: inline
In-Reply-To: <20170228.103844.1220680109576438605.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 28, 2017 at 10:38:44AM -0500, David Miller wrote:
> From: Baruch Siach <baruch@tkos.co.il>
> Date: Tue, 28 Feb 2017 10:39:48 +0200
> 
> > The email address of Jan Dumon bounces, and there is not relevant information
> > in the linked website.
> > 
> > Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> 
> This patch is fine and I will apply it later, however I will make a
> general statement that we list USB networking drivers very
> inconsistently.
> 
> Specifically, some list linux-usb as the mailing list, others list
> netdev.  We should figure out which one (or both) is the best to
> specify, and apply that rule consitently to the MAINTAINERS file.

I don't want them :)

Seriously, I don't have a problem with the patches being cc:ed to
linux-usb as long as you will take them, as often times the issues
involved are USB specific things, not network driver-specific things, so
the developers here can weigh in on them.

Want me to make up a patch to do that?

thanks,

greg k-h
