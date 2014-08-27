From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8152: replace strncpy with strlcpy
Date: Wed, 27 Aug 2014 16:18:26 -0700 (PDT)
Message-ID: <20140827.161826.1147649707339837730.davem@davemloft.net>
References: <1394712342-15778-16-Taiwan-albertk@realtek.com>
	<1394712342-15778-22-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41674 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933980AbaH0XS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 19:18:29 -0400
In-Reply-To: <1394712342-15778-22-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>
Date: Tue, 26 Aug 2014 10:08:23 +0800

> Replace the strncpy with strlcpy, and use sizeof to determine the
> length.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied, thanks.
