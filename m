From: David Miller <davem@davemloft.net>
Subject: Re: [ANNOUNCEMENT] NET: usb: sierra_net.c driver
Date: Mon, 29 Mar 2010 13:41:44 -0700 (PDT)
Message-ID: <20100329.134144.57458224.davem@davemloft.net>
References: <1269791821.11714.202.camel@localhost.localdomain>
	<4BAFAA2C.8060604@earthlink.net>
	<1269894593.11714.215.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sclark46@earthlink.net, epasheva@sierrawireless.com,
	dbrownell@users.sourceforge.net, rfiler@sierrawireless.com,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33969
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753935Ab0C2Uln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 16:41:43 -0400
In-Reply-To: <1269894593.11714.215.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Mon, 29 Mar 2010 13:29:53 -0700

> because they are not NIC cards. They just use Ethernet emulation. And
> they also require a management interface to setup APN and activate them
> first.
> 
> It is important that we tell userspace about the type of a network
> interface. We do the same for WiMAX and WiFi btw.

I completely agree with Marcel on this, please fix the device
type.
