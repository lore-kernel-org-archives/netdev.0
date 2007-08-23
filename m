From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [-MM, FIX] e1000e: incorporate napi_struct changes
 from net-2.6.24.git
Date: Thu, 23 Aug 2007 13:14:36 -0700 (PDT)
Message-ID: <20070823.131436.02270197.davem@davemloft.net>
References: <20070823145911.2467.42136.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, jeff@garzik.org,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	krkumar2@in.ibm.com
To: auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41317
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757026AbXHWUOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 16:14:38 -0400
In-Reply-To: <20070823145911.2467.42136.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Auke Kok <auke-jan.h.kok@intel.com>
Date: Thu, 23 Aug 2007 07:59:11 -0700

> This incorporates the new napi_struct changes into e1000e. Included
> bugfix for ifdown hang from Krishna Kumar for e1000.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

Acked-by: David S. Miller <davem@davemloft.net>
