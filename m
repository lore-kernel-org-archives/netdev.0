From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/2] ixgbe: remove unused functions
Date: Thu, 14 Oct 2010 10:49:59 -0700 (PDT)
Message-ID: <20101014.104959.71124768.davem@davemloft.net>
References: <20101013081759.24491.46846.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	shemminger@vyatta.com, emil.s.tantilov@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41987
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755378Ab0JNRth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 13:49:37 -0400
In-Reply-To: <20101013081759.24491.46846.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 13 Oct 2010 01:20:34 -0700

> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> Remove functions that are declared, but not used in the driver.
> This patch fixes warnings reported by `make namespacecheck`
> 
> Reported by Stephen Hemminger
> 
> CC: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Tested-by: Stephen Ko <stephen.s.ko@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
