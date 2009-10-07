From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] be2net: Get rid of net_device_stats from
 adapter.
Date: Wed, 07 Oct 2009 03:11:31 -0700 (PDT)
Message-ID: <20091007.031131.242002194.davem@davemloft.net>
References: <20091007090903.GA18843@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com, ajitkhaparde@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58560
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758080AbZJGKLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 06:11:35 -0400
In-Reply-To: <20091007090903.GA18843@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitkhaparde@gmail.com>
Date: Wed, 7 Oct 2009 14:39:16 +0530

> adapter doesnot need to maintain a copy of net_device_stats.
> Use the one already available in net_device. This patch takes care of the same.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied, thank you.

