From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] be2net: Bug Fix while accounting of multicast
 frames during netdev stats update
Date: Tue, 06 Oct 2009 17:35:30 -0700 (PDT)
Message-ID: <20091006.173530.210824666.davem@davemloft.net>
References: <20091005122140.GA22946@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50779
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933687AbZJGAff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 20:35:35 -0400
In-Reply-To: <20091005122140.GA22946@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Mon, 5 Oct 2009 17:51:51 +0530

> While updating the statistics to be passed via the get_stats,
> tx multicast frames were being accounted instead of rx multicast frames.
> This patch fixes the bug. This patch is against the net-2.6 tree.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.
