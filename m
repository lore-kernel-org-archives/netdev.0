From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 1/2] igb: defeature tx head writeback
Date: Fri, 26 Dec 2008 01:33:41 -0800 (PST)
Message-ID: <20081226.013341.00134891.davem@davemloft.net>
References: <20081224223142.12176.9916.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60030
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753395AbYLZJdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 04:33:38 -0500
In-Reply-To: <20081224223142.12176.9916.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 24 Dec 2008 14:31:42 -0800

> This patch removes tx head writeback as it was found to not provide a
> significant improvement in tx performance and on some systems has been seen
> to cause a performance degredation due to partial cache line writes.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
