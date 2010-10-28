From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000e: reset PHY after errors detected
Date: Thu, 28 Oct 2010 10:20:09 -0700 (PDT)
Message-ID: <20101028.102009.189706923.davem@davemloft.net>
References: <20101028105953.27748.5285.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	jesse.brandeburg@intel.com, carolyn.wyborny@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45551
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933965Ab0J1RTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 13:19:46 -0400
In-Reply-To: <20101028105953.27748.5285.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 28 Oct 2010 03:59:53 -0700

> From: Carolyn Wyborny <carolyn.wyborny@intel.com>
> 
> Some errors can be induced in the PHY via environmental testing
> (specifically extreme temperature changes and electro static
> discharge testing), and in the case of the PHY hanging due to
> this input, this detects the problem and resets to continue.
> This issue only applies to 82574 silicon.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
