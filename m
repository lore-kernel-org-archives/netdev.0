From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] tcp: Correction to RFC number in comment
Date: Thu, 30 Oct 2014 12:32:35 -0400 (EDT)
Message-ID: <20141030.123235.2180775200364575758.davem@davemloft.net>
References: <20141029192729.GF6582@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56582 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758636AbaJ3Qch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 12:32:37 -0400
In-Reply-To: <20141029192729.GF6582@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Wed, 29 Oct 2014 15:27:29 -0400

> Challenge ACK is described in RFC 5961, fix typo.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

This TCP change has nothing to do with your sunvnet driver changes.

Please do not ever mix unrelated changes like this within a series.

Submit the TCP change on it's own, and then respin the sunvnet
driver specific patches separately.

Thanks.
