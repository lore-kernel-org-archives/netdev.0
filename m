From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] sunvnet: Initialize network_header and
 transport_header in vnet_rx_one()
Date: Mon, 18 Jan 2016 17:22:19 -0500
Message-ID: <20160118222219.GC12034@oracle.com>
References: <20160118211209.GB12034@oracle.com>
 <20160118.172022.2052673337766512747.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rashmi.narasimhan@oracle.com,
	david.stevens@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:46024 "EHLO
	userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935028AbcATDb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 22:31:56 -0500
Received: from userp1040.oracle.com (userp1040.oracle.com [156.151.31.81])
	by userp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u0IMNPq6017544
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2016 22:23:25 GMT
Content-Disposition: inline
In-Reply-To: <20160118.172022.2052673337766512747.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/18/16 17:20), David Miller wrote:
> > Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> 
> If this is a bug fix, why are you targetting net-next?

It is a bug fix, but I was not sure if it should go into net or net-next,
so I erred on the side of caution.

--Sowmini
