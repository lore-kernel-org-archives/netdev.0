From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/4] s390: network patches for net-next
Date: Wed, 08 Sep 2010 14:31:16 -0700 (PDT)
Message-ID: <20100908.143116.02262130.davem@davemloft.net>
References: <20100908071438.085729717@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60166
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754142Ab0IHVa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 17:30:59 -0400
In-Reply-To: <20100908071438.085729717@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: frank.blaschka@de.ibm.com
Date: Wed, 08 Sep 2010 09:14:38 +0200

> here are some s390 network patches for net-next.
> We finally made it and converted the qeth layer 2 and layer 3
> driver to NAPI (thanks to Jan Glauber who did the QDIO part).

Nice work, all applied to net-next-2.6, thanks!
