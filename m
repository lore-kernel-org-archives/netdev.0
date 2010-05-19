From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/7] ixgbe: remove some redundant code in
 setting FCoE FIP filter
Date: Tue, 18 May 2010 19:44:44 -0700 (PDT)
Message-ID: <20100518.194444.73346171.davem@davemloft.net>
References: <20100519020003.18654.94899.stgit@localhost.localdomain>
	<20100519020007.18654.62574.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, yi.zou@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46538
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753683Ab0ESCof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 22:44:35 -0400
In-Reply-To: <20100519020007.18654.62574.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 18 May 2010 19:00:07 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> The ETQS setup for FIP out side the if..else is enough for the ETQS
> setup for FIP, so remove redundant code.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
