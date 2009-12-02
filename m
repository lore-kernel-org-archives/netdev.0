From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 4/9] e1000e: ensure the link state is
 correct for serdes links
Date: Wed, 02 Dec 2009 00:37:55 -0800 (PST)
Message-ID: <20091202.003755.191404899.davem@davemloft.net>
References: <20091202014931.519.25024.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53953
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753353AbZLBIht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 03:37:49 -0500
In-Reply-To: <20091202014931.519.25024.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 01 Dec 2009 17:49:51 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> This patch ensures that the link state (as reported in
> mac->serdes_has_link) will transition to false when autoneg fails to
> complete but valid codewords were detected.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
