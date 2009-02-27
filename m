From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hso: remove claiming and releasing of USB interface
Date: Thu, 26 Feb 2009 23:05:09 -0800 (PST)
Message-ID: <20090226.230509.198414661.davem@davemloft.net>
References: <20090223153932.8953.70790.stgit@Programuotojas>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	D.Barow@option.com
To: paulius.zaleckas@teltonika.lt
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59230
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753939AbZB0HFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 02:05:25 -0500
In-Reply-To: <20090223153932.8953.70790.stgit@Programuotojas>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Date: Mon, 23 Feb 2009 17:39:34 +0200

> No need to reclaim the same USB interface beeing probed.
> Releasing interface does nothing also.
> 
> This is already in for a long time in off-kernel hso driver
> and no regresions were noticed for this change.
> 
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

Applied.
