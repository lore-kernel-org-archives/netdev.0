From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rds-tcp: Add module parameters to control
 sndbuf/rcvbuf size of RDS-TCP socket
Date: Fri, 11 Mar 2016 14:14:35 -0500 (EST)
Message-ID: <20160311.141435.1989180808126737533.davem@davemloft.net>
References: <20160311182949.GG3383@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	santosh.shilimkar@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36951 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882AbcCKTOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 14:14:41 -0500
In-Reply-To: <20160311182949.GG3383@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Fri, 11 Mar 2016 13:29:49 -0500

> Some payload sizes/patterns stand to gain performance benefits by
> tuning the size of the TCP socket buffers, so this commit adds
> module parameters to customize those values when desired.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

No module parameters, please.
