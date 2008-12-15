From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 2/2] net: fix dcbnl_setnumtcs operation check
Date: Mon, 15 Dec 2008 01:06:31 -0800 (PST)
Message-ID: <20081215.010631.223311320.davem@davemloft.net>
References: <20081212095221.4416.83327.stgit@lost.foo-projects.org>
	<20081212095244.4416.19017.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	donald.c.skidmore@intel.com, eric.w.multanen@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56763
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752570AbYLOJGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 04:06:30 -0500
In-Reply-To: <20081212095244.4416.19017.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 12 Dec 2008 01:52:45 -0800

> dcbml_setnumtcs wasn't checking for the presence of the setnumtcs
> function.  Instead, it was checking for setstate which was a bug.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Eric W Multanen <eric.w.multanen@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
