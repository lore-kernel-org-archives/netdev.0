From: David Miller <davem@davemloft.net>
Subject: Re: Bluetooth fixes for 2.6.20-rc5
Date: Tue, 23 Jan 2007 22:03:03 -0800 (PST)
Message-ID: <20070123.220303.59657561.davem@davemloft.net>
References: <1169502134.27023.24.camel@violet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48536
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965543AbXAXGDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 01:03:04 -0500
In-Reply-To: <1169502134.27023.24.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann <marcel@holtmann.org>
Date: Mon, 22 Jan 2007 22:42:14 +0100

> Hi Dave,
> 
> here are two additional fixes for the Bluetooth subsystem that should go
> in before the final 2.6.20 release. It was possible that the well known
> PSM could be bound by anybody. That should not be possible like TCP/IP
> ports below 1024 are also restricted. The other one is a simple endian
> fix. Please forward them to Linus as soon as possible.

Pulled, thanks Marcel.

BTW, do you know if anyone has successfully used the Linux
Bluetooth stack to communicate with the Nintendo Wii
controllers?  I am under the impression that they speak
bluetooth. :)

