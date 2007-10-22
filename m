From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Bluetooth patches for 2.6.24
Date: Mon, 22 Oct 2007 09:56:31 +0200
Message-ID: <1193039791.6184.154.camel@violet>
References: <1192888816.6184.117.camel@violet>
	 <1192910497.6184.134.camel@violet>
	 <20071021.162614.58462652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:59116 "EHLO
	mail.holtmann.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532AbXJVHzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 03:55:22 -0400
In-Reply-To: <20071021.162614.58462652.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

> > > these are the Bluetooth patches for the 2.6.24 kernel release. Please
> > > pull and send them to Linus.
> > 
> > one of the cleanup patches slipped through the net. If you already
> > pulled my tree, then please re-pull. I pushed it on top of it.
> 
> I think I got it all, thanks.
> 
> Please get Bluetooth updates to me much sooner than 8
> days after the merge window opens up.

sorry for that, but I wanted to make sure that the new generic Bluetooth
SDIO driver makes it in and is working with the SDIO framework merge.

For the next releases, I don't see any dependencies on other merges, so
that should be no longer problem. Thanks for pulling.

Regards

Marcel


