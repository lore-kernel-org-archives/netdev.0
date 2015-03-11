From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: bcmgenet: collect Rx discarded packet
 count
Date: Wed, 11 Mar 2015 17:55:13 -0400 (EDT)
Message-ID: <20150311.175513.383437545392072191.davem@davemloft.net>
References: <20150310225500.8FA34220365@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52422 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569AbbCKVzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 17:55:14 -0400
In-Reply-To: <20150310225500.8FA34220365@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Tue, 10 Mar 2015 15:55:00 -0700 (PDT)

> Bits 31:16 of RDMA_PROD_INDEX contain Rx discarded packet count, which
> are the Rx packets that had to be dropped by MAC hardware since there
> was no room on the Rx queue. Add code to collect this information into
> the netdev stats.
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

Applied, thanks.
