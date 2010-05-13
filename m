From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 03/12] e1000e: initialize manageability
 (IPMI) pass-through in 82574/82583
Date: Wed, 12 May 2010 23:31:56 -0700 (PDT)
Message-ID: <20100512.233156.183060483.davem@davemloft.net>
References: <20100511005801.30827.50808.stgit@localhost.localdomain>
	<20100511005949.30827.62576.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45016
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753759Ab0EMGbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 02:31:48 -0400
In-Reply-To: <20100511005949.30827.62576.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 10 May 2010 17:59:51 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> 82574/82583 uses different registers/bits to setup manageability filters
> than all other parts supported by e1000e; set them accordingly for IPMI
> pass-through.  Rename the function to better reflect what it does.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
