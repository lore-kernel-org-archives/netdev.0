From: David Miller <davem@davemloft.net>
Subject: Re: Bluetooth fixes for 2.6.20-rc5
Date: Tue, 23 Jan 2007 22:44:04 -0800 (PST)
Message-ID: <20070123.224404.70218891.davem@davemloft.net>
References: <1169502134.27023.24.camel@violet>
	<20070123.220303.59657561.davem@davemloft.net>
	<1169624333.15396.2.camel@aeonflux.holtmann.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60799
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933116AbXAXGoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 01:44:10 -0500
In-Reply-To: <1169624333.15396.2.camel@aeonflux.holtmann.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann <marcel@holtmann.org>
Date: Wed, 24 Jan 2007 08:38:53 +0100

> I have one of these and I played with it. They use HID over Bluetooth as
> protocol, but all reports are vendor specific. So you need a specific
> driver to make something useful out of these events.

It really shouldn't be hard to reverse engineer this right?
Just press a button and see what it spits out?

Sure, the rotational events from the motion sensor et al. might take a
little time to figure out, but it should be doable.

> However it is fun to switch on the leds and play with rumble pack or
> motion sensor.

Hehe :-)
