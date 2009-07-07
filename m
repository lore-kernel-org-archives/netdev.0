From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] dm9000: add checksum offload support
Date: Mon, 06 Jul 2009 18:13:02 -0700 (PDT)
Message-ID: <20090706.181302.109020502.davem@davemloft.net>
References: <4A519F1F.90706@compulab.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben-linux-arm@fluff.org, yeasah@comrex.com,
	romieu@fr.zoreil.com
To: mike@compulab.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32987
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753339AbZGGBMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 21:12:55 -0400
In-Reply-To: <4A519F1F.90706@compulab.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Rapoport <mike@compulab.co.il>
Date: Mon, 06 Jul 2009 09:52:15 +0300

>> From: Yeasah Pell <yeasah@comrex.com>
> 
> Add checksum offload support for DM9000A and DM9000B chips.
> 
> --
> v2 changes: added a local copy of ip_summed to save IO cycles in dm9000_send_packet
> v3 changes: trans_start updating is removed.
> 
> Signed-off-by: Yeasah Pell <yeasah@comrex.com>
> Signed-off-by: Mike Rapoport <mike@compulab.co.il>

Applied to net-next-2.6, thanks.
