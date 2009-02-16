From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/6] igb: reduce size required to trigger low
 latency
Date: Mon, 16 Feb 2009 00:06:29 -0800 (PST)
Message-ID: <20090216.000629.59039371.davem@davemloft.net>
References: <20090213041654.3848.39227.stgit@lost.foo-projects.org>
	<20090213041721.3848.61896.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38891
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754042AbZBPIGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 03:06:45 -0500
In-Reply-To: <20090213041721.3848.61896.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 12 Feb 2009 20:17:21 -0800

> Update the Adaptive Interrupt Moderation algorithm so that the low latency
> state is triggered less easily to prevent high interrupt loads.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
