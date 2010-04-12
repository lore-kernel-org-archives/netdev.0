From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-2.6 PATCH] ixgbe: fix bug with vlan strip in promsic mode
Date: Mon, 12 Apr 2010 14:40:09 -0700
Message-ID: <1271108409.23823.0.camel@localhost>
References: <20100325213428.8089.1879.stgit@localhost.localdomain>
	 <20100326.210052.169199791.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11661 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753581Ab0DLVkK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 17:40:10 -0400
In-Reply-To: <20100326.210052.169199791.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-03-26 at 22:00 -0600, David Miller wrote:
> Doesn't apply.
> 
> It depends upon the mc_list traversal conversions which are
> absolutely not appropriate for net-2.6, and thus I only
> applied to net-next-2.6

Dave,
	I am not seeing this patch in your net-next tree.  Do you want me to
re-submit the patch against net-next?

Cheers,
Jeff

