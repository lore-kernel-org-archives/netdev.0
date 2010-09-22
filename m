From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] atl1: zero out CMB and SBM in
 atl1_free_ring_resources
Date: Wed, 22 Sep 2010 13:53:34 -0700 (PDT)
Message-ID: <20100922.135334.245404482.davem@davemloft.net>
References: <20100922.132341.48506736.davem@davemloft.net>
	<20100922204231.GA1401@nb-core2.darkstar.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, atl1-devel@lists.sourceforge.net,
	jcliburn@gmail.com, chris.snook@gmail.com, jie.yang@atheros.com
To: kronos.it@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42224
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755265Ab0IVUxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 16:53:15 -0400
In-Reply-To: <20100922204231.GA1401@nb-core2.darkstar.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luca Tettamanti <kronos.it@gmail.com>
Date: Wed, 22 Sep 2010 22:42:31 +0200

> They are allocated in atl1_setup_ring_resources, zero out the pointers
> in atl1_free_ring_resources (like the other resources).
> 
> Signed-off-by: Luca Tettamanti <kronos.it@gmail.com>
> Acked-by: Chris Snook <chris.snook@gmail.com>

Applied.
