From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 2/2] pkt_action: add new action skbedit
Date: Fri, 12 Sep 2008 16:30:29 -0700 (PDT)
Message-ID: <20080912.163029.107177209.davem@davemloft.net>
References: <20080912224438.6940.77624.stgit@jtkirshe-mobile.jf.intel.com>
	<20080912224501.6940.56702.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55562
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755650AbYILXaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 19:30:35 -0400
In-Reply-To: <20080912224501.6940.56702.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 12 Sep 2008 15:45:15 -0700

> This new action will have the ability to change the priority and/or
> queue_mapping fields on an sk_buff.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
