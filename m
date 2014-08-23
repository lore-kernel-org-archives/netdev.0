From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] r8152: firmware support
Date: Fri, 22 Aug 2014 19:41:11 -0700 (PDT)
Message-ID: <20140822.194111.760144805197214266.davem@davemloft.net>
References: <1394712342-15778-16-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56842 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776AbaHWClO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 22:41:14 -0400
In-Reply-To: <1394712342-15778-16-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>
Date: Wed, 20 Aug 2014 16:58:35 +0800

> Parsing, checking, and writing the firmware.

You haven't told us why you need to do this.

These are just programming registers in the chip, and I see no reason
to not keep these in the driver with real code.

I'm not applying this series, you haven't explained what is happening
here and the reason for doing so.  Ironically, that's exactly what you
are supposed to provide in this 0/4 header email.
