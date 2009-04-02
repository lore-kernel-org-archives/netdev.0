From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/9] ixgbe: fix build when DEBUG is defined
Date: Thu, 02 Apr 2009 01:15:09 -0700 (PDT)
Message-ID: <20090402.011509.74006066.davem@davemloft.net>
References: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60294
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753277AbZDBIPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:15:20 -0400
In-Reply-To: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 01 Apr 2009 00:32:42 -0700

> The ixgbe driver had issues when DEBUG was defined because the hw_dbg macro
> was incomplete.  This patch completes the code based off of the code that
> already existed in the igb module.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
