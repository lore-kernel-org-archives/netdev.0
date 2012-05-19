From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] USB CDC-Ether - Add ZTE WWAN matches before generic
 Ethernet
Date: Sat, 19 May 2012 18:48:12 -0400 (EDT)
Message-ID: <20120519.184812.2116650800791553287.davem@davemloft.net>
References: <1337435767-9544-1-git-send-email-ajb@spheresystems.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.name, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ajb@spheresystems.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53160 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754872Ab2ESWsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 18:48:24 -0400
In-Reply-To: <1337435767-9544-1-git-send-email-ajb@spheresystems.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Bird <ajb@spheresystems.co.uk>
Date: Sat, 19 May 2012 14:56:07 +0100

> Some ZTE WWAN devices have generic CDC Ether descriptors. Add those
> into the whitelist so that we get FLAG_WWAN on the interface
> 
> Signed-off-by: Andrew Bird <ajb@spheresystems.co.uk>

Applied.

But I changed the Subject line to have a more appropriate prefix,
namely "net: cdc_ether: "
