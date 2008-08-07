From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 4/4] e1000e: remove inapplicable test for ioport
Date: Thu, 07 Aug 2008 01:56:12 -0400
Message-ID: <489A8E7C.7040303@garzik.org>
References: <20080805002030.24137.10360.stgit@localhost.localdomain> <20080805002145.24137.80353.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org, Bruce Allan <bruce.w.allan@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60331 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753415AbYHGHAz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 03:00:55 -0400
In-Reply-To: <20080805002145.24137.80353.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> There are currently no devices supported by the e1000e driver which need
> ioport resources, remove the test for it and all unnecessary code
> associated with it (struct e1000_adapter elements, local variables, etc.)
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

applied 1-4


