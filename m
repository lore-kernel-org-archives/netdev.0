From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] igb: cleanup igb loopback path
Date: Thu, 02 Apr 2009 01:00:09 -0700 (PDT)
Message-ID: <20090402.010009.170612185.davem@davemloft.net>
References: <20090401063759.3046.89960.stgit@lost.foo-projects.org>
	<20090401063856.3046.80012.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41764
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756810AbZDBIAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:00:20 -0400
In-Reply-To: <20090401063856.3046.80012.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 31 Mar 2009 23:38:56 -0700

> The code path for setting up phy loopback testing was out of date and was
> setting bits it didn't need to.  This change cleans up the code path and
> removes some code that has no effect on teh driver.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
