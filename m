From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/9] ixgbe: feature - driver to default with FC on.
Date: Thu, 02 Apr 2009 01:15:35 -0700 (PDT)
Message-ID: <20090402.011535.149706947.davem@davemloft.net>
References: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
	<20090401073343.3749.23654.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	donald.c.skidmore@intel.com, mallikarjuna.chilakala@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60306
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756285AbZDBIPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:15:46 -0400
In-Reply-To: <20090401073343.3749.23654.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 01 Apr 2009 00:33:44 -0700

> In the past flow control wasn't enabled by default under the
> incorrect assumption that this opened up us to a denial of
> service attack.  However since any switch that forwarded flow
> control would be extremely msiconfigured and/or buggy, this
> concern no longer out weighs the preformance gains from
> having FC enabled.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Acked-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
