From: David Miller <davem@davemloft.net>
Subject: Re: [Resend] [PATCH] bonding: change some __constant_htons() to
 htons()
Date: Tue, 02 Sep 2008 14:02:49 -0700 (PDT)
Message-ID: <20080902.140249.187369035.davem@davemloft.net>
References: <48BD48C8.1090806@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, fubar@us.ibm.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54327
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754269AbYIBVCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 17:02:55 -0400
In-Reply-To: <48BD48C8.1090806@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Tue, 02 Sep 2008 10:08:08 -0400

> Change __constant_htons() to htons() in the bonding driver, it should
> only be used for initializers.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Looks good to me:

Acked-by: David S. Miller <davem@davemloft.net>
