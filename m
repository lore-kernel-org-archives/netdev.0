From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 1/2] igb: update handling of RCTL for smaller
 buffer sizes
Date: Wed, 10 Dec 2008 01:09:24 -0800 (PST)
Message-ID: <20081210.010924.203805374.davem@davemloft.net>
References: <20081210024156.27280.78618.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53393
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751531AbYLJJJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 04:09:23 -0500
In-Reply-To: <20081210024156.27280.78618.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 09 Dec 2008 18:41:57 -0800

> As we begin to move into virtualization the use of a global value for
> buffer sizes becomes undesirable.  This change makes it so only 256 and 512
> byte buffers require use of the RCTL register.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
