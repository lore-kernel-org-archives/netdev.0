From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] e1000e: remove workaround for e1000 hardware
Date: Wed, 18 Feb 2009 19:34:12 -0800 (PST)
Message-ID: <20090218.193412.99248270.davem@davemloft.net>
References: <20090218092451.21312.80460.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57022
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752274AbZBSDe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 22:34:28 -0500
In-Reply-To: <20090218092451.21312.80460.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 18 Feb 2009 01:24:51 -0800

> During the move of support for PCIe devices from e1000 to e1000e,
> this workaround necessary only for older non-PCIe devices was
> mistakenly copied into e1000e.  Remove it.
>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Acked-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
