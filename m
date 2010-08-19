From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 11/20] ixgbe: bump PS header size to 512
 bytes
Date: Thu, 19 Aug 2010 16:46:46 -0700 (PDT)
Message-ID: <20100819.164646.28790675.davem@davemloft.net>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
	<20100819233719.10335.25526.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60461
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753981Ab0HSXq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:46:29 -0400
In-Reply-To: <20100819233719.10335.25526.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Aug 2010 16:37:21 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> Bump the header size for packet split to 512 bytes since this makes the
> best use of the 1k buffer that is allocated for any skb 512 bytes or
> smaller.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
