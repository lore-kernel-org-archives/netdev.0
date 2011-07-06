From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usb: usbnet: suspend count gets lost when -EBUSY
Date: Tue, 05 Jul 2011 18:40:26 -0700 (PDT)
Message-ID: <20110705.184026.248634180411066869.davem@davemloft.net>
References: <CADuEq9BQX2BFBY3pF=CEEymfK4JPwMP7By+JZFdaLqxs+GhtJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
To: C.Fries@motorola.com, qcf001@motorola.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51026 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755224Ab1GFBkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 21:40:32 -0400
In-Reply-To: <CADuEq9BQX2BFBY3pF=CEEymfK4JPwMP7By+JZFdaLqxs+GhtJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Fries <qcf001@motorola.com>
Date: Tue, 5 Jul 2011 20:35:05 -0500

> +++ b/drivers/net/usb/usbnet.c
> @@ -1451,6 +1451,7 @@ int usbnet_suspend (struct usb_interface *intf,
> pm_message_t message)

Your email client has mangled your patch, please read
"Documentation/email-clients.txt" on how to fix this.

Once you've fixed it, email the patch to yourself and
verify that you yourself can successfully apply the
patch you receive.
