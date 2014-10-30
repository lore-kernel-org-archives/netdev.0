From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 1/3] tcp: Correction to RFC number in comment
Date: Thu, 30 Oct 2014 12:51:02 -0400
Message-ID: <20141030165102.GI650@oracle.com>
References: <20141029192729.GF6582@oracle.com>
 <20141030.123235.2180775200364575758.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42399 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758922AbaJ3QvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 12:51:08 -0400
Content-Disposition: inline
In-Reply-To: <20141030.123235.2180775200364575758.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (10/30/14 12:32), David Miller wrote:
> 
> Please do not ever mix unrelated changes like this within a series.
> 
> Submit the TCP change on it's own, and then respin the sunvnet
> driver specific patches separately.

Done. 

fwiw, I ran into this comment when debugging something in sunvnet,
and was quite confused by the rfc 5691 reference :-)

--Sowmini
