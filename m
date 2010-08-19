From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 13/20] ixgbe: Move max frame size and Rx
 buffer length configuration into a function
Date: Thu, 19 Aug 2010 16:46:56 -0700 (PDT)
Message-ID: <20100819.164656.179957143.davem@davemloft.net>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
	<20100819233808.10335.36102.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60436
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753981Ab0HSXqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:46:39 -0400
In-Reply-To: <20100819233808.10335.36102.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Aug 2010 16:38:11 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change consolidates all of the Rx max frame size and Rx buffer length
> configuration into a single function.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
