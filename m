From: David Miller <davem@davemloft.net>
Subject: Re: [patch 09/15] SPIN_LOCK_UNLOCKED cleanup in drivers/atm, net
Date: Thu, 26 Apr 2007 01:37:57 -0700 (PDT)
Message-ID: <20070426.013757.131104778.davem@davemloft.net>
References: <200704260727.l3Q7RSwf023967@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, milindchoudhary@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56514
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933613AbXDZIhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 04:37:48 -0400
In-Reply-To: <200704260727.l3Q7RSwf023967@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Thu, 26 Apr 2007 00:27:28 -0700

> From: Milind Arun Choudhary <milindchoudhary@gmail.com>
> 
> SPIN_LOCK_UNLOCKED cleanup,use __SPIN_LOCK_UNLOCKED instead
> 
> Signed-off-by: Milind Arun Choudhary <milindchoudhary@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
