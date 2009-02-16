From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/6] igb: cleanup incorrect comment and set IP
 Checksum Enable
Date: Mon, 16 Feb 2009 00:06:36 -0800 (PST)
Message-ID: <20090216.000636.123588245.davem@davemloft.net>
References: <20090213041654.3848.39227.stgit@lost.foo-projects.org>
	<20090213041742.3848.64015.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	alexander.h.duyck@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38896
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754071AbZBPIGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 03:06:52 -0500
In-Reply-To: <20090213041742.3848.64015.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 12 Feb 2009 20:17:42 -0800

> IP Checksum enable doesn't need packet split in order to function.  It only
> requires the use of advanced descriptors which the current igb driver does.
> So we can enable it always without any issues.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
