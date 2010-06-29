From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] caif: Kconfig and Makefile fixes
Date: Tue, 29 Jun 2010 00:08:56 -0700 (PDT)
Message-ID: <20100629.000856.13749890.davem@davemloft.net>
References: <20100625.211223.232914661.davem@davemloft.net>
	<1277587889-17314-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjurbr@gmail.com, netdev@vger.kernel.org, marcel@holtmann.org,
	daniel.martensson@stericsson.com, linus.walleij@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43136
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752213Ab0F2HIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 03:08:44 -0400
In-Reply-To: <1277587889-17314-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sjur.brandeland@stericsson.com
Date: Sat, 26 Jun 2010 23:31:28 +0200

> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 
> Use "depends on" instead of "if" in Kconfig files.
> Fixed CAIF debug flag, and removed unnecessary clean-* options.
> 
> Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>

Applied.
