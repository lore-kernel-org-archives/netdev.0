From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] igb: add support for x2 link width configurations
Date: Thu, 02 Apr 2009 00:59:47 -0700 (PDT)
Message-ID: <20090402.005947.125182670.davem@davemloft.net>
References: <20090401063759.3046.89960.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41752
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750950AbZDBH77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 03:59:59 -0400
In-Reply-To: <20090401063759.3046.89960.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 31 Mar 2009 23:38:00 -0700

> When device is on PCIe link trained as x2 the driver is currently reporting
> link width as "unknown".  The original patch provided by Myron adds the x2
> link support and my changes are cosmetic to clean up the readability of the
> conditional operators.
> 
> Based on work by: Myron Stowe <myron.stowe@hp.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
