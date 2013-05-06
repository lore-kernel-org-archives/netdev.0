From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFT] 3c59x: fix freeing nonexistent resource on driver
 unload
Date: Mon, 06 May 2013 16:50:18 -0400 (EDT)
Message-ID: <20130506.165018.1267090005146246869.davem@davemloft.net>
References: <201305030110.22462.sergei.shtylyov@cogentembedded.com>
	<20130506.122236.49412750367407481.davem@davemloft.net>
	<5188166A.2050200@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de,
	tedheadster@gmail.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35106 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756549Ab3EFUuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 16:50:24 -0400
In-Reply-To: <5188166A.2050200@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Tue, 07 May 2013 00:45:30 +0400

>    Will you queue this patch for stable?

Done.
