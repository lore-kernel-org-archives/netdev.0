From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 3/5] e1000: cleanup link up/down messages
Date: Thu, 27 Nov 2008 00:22:52 -0800 (PST)
Message-ID: <20081127.002252.56967128.davem@davemloft.net>
References: <20081127000206.22431.53339.stgit@gitlost.lost>
	<20081127000235.22431.40175.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38452
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752576AbYK0IWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 03:22:52 -0500
In-Reply-To: <20081127000235.22431.40175.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 26 Nov 2008 16:02:35 -0800

> The system log messages created on a link status change need to follow a
> specific format to work with tools some customers use.  This also makes
> the messages consistant with other Intel driver link messages.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
