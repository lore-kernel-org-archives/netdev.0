From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Bluetooth fixes for 2.6.20-rc5
Date: Wed, 24 Jan 2007 08:38:53 +0100
Message-ID: <1169624333.15396.2.camel@aeonflux.holtmann.net>
References: <1169502134.27023.24.camel@violet>
	 <20070123.220303.59657561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:47391 "EHLO
	mail.holtmann.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933034AbXAXGis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 01:38:48 -0500
In-Reply-To: <20070123.220303.59657561.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

> BTW, do you know if anyone has successfully used the Linux
> Bluetooth stack to communicate with the Nintendo Wii
> controllers?  I am under the impression that they speak
> bluetooth. :)

I have one of these and I played with it. They use HID over Bluetooth as
protocol, but all reports are vendor specific. So you need a specific
driver to make something useful out of these events.

However it is fun to switch on the leds and play with rumble pack or
motion sensor.

Regards

Marcel


