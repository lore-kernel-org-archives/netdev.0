From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: wake up the device before dumping the hw
 counter
Date: Tue, 08 Jul 2014 19:55:49 -0700 (PDT)
Message-ID: <20140708.195549.779368337637597360.davem@davemloft.net>
References: <1394712342-15778-5-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55991 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbaGICzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 22:55:50 -0400
In-Reply-To: <1394712342-15778-5-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>
Date: Tue, 8 Jul 2014 14:49:28 +0800

> The device should be waked up from runtime suspend before dumping
> the hw counter.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied, thanks.
