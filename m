From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/5] igb: add pf side of VMDq support
Date: Fri, 20 Feb 2009 00:23:33 -0800 (PST)
Message-ID: <20090220.002333.43185677.davem@davemloft.net>
References: <20090220043902.29650.35055.stgit@lost.foo-projects.org>
	<20090220043944.29650.38934.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com, yu.zhao@intel.com,
	linux-kernel@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49554
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754543AbZBTIXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 03:23:52 -0500
In-Reply-To: <20090220043944.29650.38934.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Feb 2009 20:39:44 -0800

> Add the pf portion of vmdq support.  This provides enough support so that
> VMDq is enabled, and the pf is functional without enabling vfs.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
