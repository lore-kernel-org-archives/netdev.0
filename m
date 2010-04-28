From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] net/usb: add sierra_net.c driver
Date: Tue, 27 Apr 2010 18:07:32 -0700 (PDT)
Message-ID: <20100427.180732.121248582.davem@davemloft.net>
References: <1272415711.10975.3.camel@Linuxdev4-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dbrownell@users.sourceforge.net, rfiler@sierrawireless.com,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: epasheva@sierrawireless.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57904
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754594Ab0D1BH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 21:07:27 -0400
In-Reply-To: <1272415711.10975.3.camel@Linuxdev4-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elina Pasheva <epasheva@sierrawireless.com>
Date: Tue, 27 Apr 2010 17:48:31 -0700

> Subject: [PATCH v5] net/usb: add sierra_net.c driver

Applied, although I had to manually remove the stray extra
newline at the end of drivers/net/usb/sierra_net.c which GIT
complains about when the patch is applied.
