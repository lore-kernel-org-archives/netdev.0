From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Bluetooth fixes for 2.6.20-rc5
Date: Wed, 24 Jan 2007 09:33:50 +0100
Message-ID: <1169627630.20178.2.camel@aeonflux.holtmann.net>
References: <1169502134.27023.24.camel@violet>
	 <20070123.220303.59657561.davem@davemloft.net>
	 <1169624333.15396.2.camel@aeonflux.holtmann.net>
	 <20070123.224404.70218891.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:47467 "EHLO
	mail.holtmann.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933187AbXAXHde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 02:33:34 -0500
In-Reply-To: <20070123.224404.70218891.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

> > I have one of these and I played with it. They use HID over Bluetooth as
> > protocol, but all reports are vendor specific. So you need a specific
> > driver to make something useful out of these events.
> 
> It really shouldn't be hard to reverse engineer this right?
> Just press a button and see what it spits out?
> 
> Sure, the rotational events from the motion sensor et al. might take a
> little time to figure out, but it should be doable.

some stuff has already been done in this area. I put some information
and a link to it on my page:

http://www.holtmann.org/linux/bluetooth/wiimote.html

The hardest part at the moment is to get the speaker on the Wiimote
doing something useful and I personally wanna get to the internal flash
area of the Bluetooth chip.

Regards

Marcel


