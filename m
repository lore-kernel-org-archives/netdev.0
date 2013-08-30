From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH 10/31] net: fec: use dev_get_platdata()
Date: Fri, 30 Aug 2013 05:23:06 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE016632EE@039-SN2MPN1-021.039d.mgd.msft.net>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
 <003a01cea53d$486e7670$d94b6350$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jingoo Han <jg1.han@samsung.com>,
	"'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0249.outbound.messaging.microsoft.com ([213.199.154.249]:13116
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752353Ab3H3FYN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 01:24:13 -0400
In-Reply-To: <003a01cea53d$486e7670$d94b6350$%han@samsung.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han<jg1.han@samsung.com>
Data: Friday, August 30, 2013 12:56 PM +0900

> To: 'David S. Miller'
> Cc: netdev@vger.kernel.org; 'Jingoo Han'
> Subject: [PATCH 10/31] net: fec: use dev_get_platdata()
> 
> Use the wrapper function for retrieving the platform data instead of
> accessing dev->platform_data directly. This is a cosmetic change to make
> the code simpler and enhance the readability.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Acked-by: Fugang Duan  <B38611@freescale.com>

Regards
Andy
