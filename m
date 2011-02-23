From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH] e1000: fix sparse warning
Date: Wed, 23 Feb 2011 10:24:07 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1102231022340.5424@JBRANDEB-DESK2.amr.corp.intel.com>
References: <20110223101203.0894c474@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55021 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753621Ab1BWSYL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 13:24:11 -0500
In-Reply-To: <20110223101203.0894c474@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 23 Feb 2011, Stephen Hemminger wrote:

> Sparse complains because the e1000 driver is calling ioread on a pointer
> not tagged as __iomem.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Seems fine, thanks Stephen.

Reviewed-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

 
