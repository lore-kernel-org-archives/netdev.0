From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net/usb: remove default in Kconfig for sierra_net
 driver
Date: Fri, 30 Apr 2010 19:05:38 -0700 (PDT)
Message-ID: <20100430.190538.228966247.davem@davemloft.net>
References: <1272672300.7581.2.camel@Linuxdev4-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dbrownell@users.sourceforge.net, rfiler@sierrawireless.com,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: epasheva@sierrawireless.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48350
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757806Ab0EACFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 22:05:34 -0400
In-Reply-To: <1272672300.7581.2.camel@Linuxdev4-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elina Pasheva <epasheva@sierrawireless.com>
Date: Fri, 30 Apr 2010 17:05:00 -0700

> Subject: [PATCH 1/1] net/usb: remove default in Kconfig for sierra_net driver
> From: Elina Pasheva <epasheva@sierrawireless.com>
> 
> The following patch removes the default from the Kconfig entry for sierra_net
> driver as recommended.
> All non-core drivers should default to "n".
> This patch has been checked against net-2.6 tree.
> Signed-off-by: Elina Pasheva <epasheva@sierrawireless.com>
> Signed-off-by: Rory Filer <rfiler@sierrawireless.com>

Applied, thanks.
