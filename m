From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/4] Add support for Classifier and RSS
Date: Wed, 17 Feb 2016 22:08:58 -0500 (EST)
Message-ID: <20160217.220858.1360154606807063304.davem@davemloft.net>
References: <1455750042-1521-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, patches@apm.com,
	toanle@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33469 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424050AbcBRDJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 22:09:01 -0500
In-Reply-To: <1455750042-1521-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Wed, 17 Feb 2016 15:00:38 -0800

> This patch set enables,
> 
> (i) Classifier engine that is used for parsing
> through the packet and extracting a search string that is then used
> to search a database to find associative data.
> 
> (ii) Receive Side Scaling (RSS) that does dynamic load
> balancing of the CPUs by controlling the number of messages enqueued
> per CPU though the help of Toeplitz Hash function of 4-tuple of
> source TCP/UDP port, destination TCP/UDP port, source IPV4 address and
> destination IPV4 address.
> 
> (iii) Multi queue, to make advantage of RSS
 ...

Series applied, thanks.
